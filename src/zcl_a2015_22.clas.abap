CLASS zcl_a2015_22 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_state,
             hit_points TYPE i,
             mana TYPE i,
             boss_hp TYPE i,
             shield TYPE i,
             poison TYPE i,
             recharge TYPE i,
             spent TYPE i,
             estimate TYPE i,
           END OF ty_state.
    TYPES tt_states TYPE STANDARD TABLE OF ty_state WITH EMPTY KEY.
    TYPES tt_frontier TYPE SORTED TABLE OF ty_state WITH NON-UNIQUE KEY estimate boss_hp spent.
    TYPES tt_seen TYPE HASHED TABLE OF ty_state
      WITH UNIQUE KEY mana boss_hp shield poison recharge.
    DATA mv_boss_hp TYPE i.
    DATA mv_boss_damage TYPE i.
    DATA mv_result1 TYPE string.
    DATA mv_result2 TYPE string.
    METHODS apply_effects CHANGING cs_state TYPE ty_state.
    METHODS boss_turn CHANGING cs_state TYPE ty_state.
    METHODS remember_state
      IMPORTING is_state TYPE ty_state
      CHANGING ct_seen TYPE tt_seen
      RETURNING VALUE(rv_new) TYPE abap_bool.
    METHODS cast_spell
      IMPORTING iv_spell TYPE i
      CHANGING cs_state TYPE ty_state
      RETURNING VALUE(rv_cast) TYPE abap_bool.
    METHODS successors
      IMPORTING is_state TYPE ty_state iv_hard TYPE abap_bool
      RETURNING VALUE(rt_states) TYPE tt_states.
    METHODS least_mana
      IMPORTING iv_hard TYPE abap_bool DEFAULT abap_false
                iv_hit_points TYPE i DEFAULT 50
                iv_mana TYPE i DEFAULT 500
      RETURNING VALUE(rv_mana) TYPE i.
ENDCLASS.

CLASS zcl_a2015_22 IMPLEMENTATION.
  METHOD init.
    CLEAR: mv_boss_hp, mv_boss_damage, mv_result1, mv_result2.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = condense( <lv_line> ).
      CHECK lv_line IS NOT INITIAL.
      SPLIT lv_line AT ':' INTO DATA(lv_name) DATA(lv_value).
      CASE lv_name.
        WHEN 'Hit Points'. mv_boss_hp = CONV i( condense( lv_value ) ).
        WHEN 'Damage'. mv_boss_damage = CONV i( condense( lv_value ) ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_effects.
    cs_state-boss_hp = cs_state-boss_hp - COND i( WHEN cs_state-poison > 0 THEN 3 ELSE 0 ).
    cs_state-mana = cs_state-mana + COND i( WHEN cs_state-recharge > 0 THEN 101 ELSE 0 ).
    cs_state-shield = nmax( val1 = 0 val2 = cs_state-shield - 1 ).
    cs_state-poison = nmax( val1 = 0 val2 = cs_state-poison - 1 ).
    cs_state-recharge = nmax( val1 = 0 val2 = cs_state-recharge - 1 ).
  ENDMETHOD.

  METHOD cast_spell.
    DATA(lv_cost) = SWITCH i( iv_spell WHEN 1 THEN 53 WHEN 2 THEN 73
                                       WHEN 3 THEN 113 WHEN 4 THEN 173 WHEN 5 THEN 229 ELSE 0 ).
    CHECK lv_cost > 0 AND cs_state-mana >= lv_cost.
    CHECK iv_spell <> 3 OR cs_state-shield = 0.
    CHECK iv_spell <> 4 OR cs_state-poison = 0.
    CHECK iv_spell <> 5 OR cs_state-recharge = 0.
    cs_state-mana = cs_state-mana - lv_cost.
    cs_state-spent = cs_state-spent + lv_cost.
    CASE iv_spell.
      WHEN 1. cs_state-boss_hp = cs_state-boss_hp - 4.
      WHEN 2.
        cs_state-boss_hp = cs_state-boss_hp - 2.
        cs_state-hit_points = cs_state-hit_points + 2.
      WHEN 3. cs_state-shield = 6.
      WHEN 4. cs_state-poison = 6.
      WHEN 5. cs_state-recharge = 5.
    ENDCASE.
    rv_cast = abap_true.
  ENDMETHOD.

  METHOD boss_turn.
    CHECK cs_state-boss_hp > 0.
    apply_effects( CHANGING cs_state = cs_state ).
    CHECK cs_state-boss_hp > 0.
    DATA(lv_armor) = COND i( WHEN cs_state-shield > 0 THEN 7 ELSE 0 ).
    cs_state-hit_points = cs_state-hit_points - nmax( val1 = 1 val2 = mv_boss_damage - lv_armor ).
  ENDMETHOD.

  METHOD successors.
    DATA(ls_state) = is_state.
    " Hard mode damage occurs before effects, including a potentially lethal poison tick.
    ls_state-hit_points = ls_state-hit_points - COND i( WHEN iv_hard = abap_true THEN 1 ELSE 0 ).
    CHECK ls_state-hit_points > 0.
    apply_effects( CHANGING cs_state = ls_state ).
    IF ls_state-boss_hp <= 0.
      APPEND ls_state TO rt_states.
      RETURN.
    ENDIF.
    DO 5 TIMES.
      DATA(lv_spell) = sy-index.
      DATA(ls_next) = ls_state.
      CHECK cast_spell( EXPORTING iv_spell = lv_spell CHANGING cs_state = ls_next ) = abap_true.
      " An instant kill ends combat before any boss-turn effects or attack.
      boss_turn( CHANGING cs_state = ls_next ).
      CHECK ls_next-hit_points > 0.
      APPEND ls_next TO rt_states.
    ENDDO.
  ENDMETHOD.

  METHOD least_mana.
    " Optimistic damage-only cost: allow unlimited Poison and Magic Missile,
    " ignoring survival, mana availability and effect overlap. This is a lower
    " bound, so A* can skip expensive paths without skipping the cheapest win.
    DATA lt_cost TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    APPEND 0 TO lt_cost.
    DO mv_boss_hp TIMES.
      DATA(lv_damage) = sy-index.
      DATA(lv_missile_index) = nmax( val1 = 0 val2 = lv_damage - 4 ) + 1.
      DATA(lv_poison_index) = nmax( val1 = 0 val2 = lv_damage - 18 ) + 1.
      APPEND nmin( val1 = 53 + lt_cost[ lv_missile_index ]
                   val2 = 173 + lt_cost[ lv_poison_index ] ) TO lt_cost.
    ENDDO.
    DATA(lt_frontier) = VALUE tt_frontier(
      ( hit_points = iv_hit_points mana = iv_mana boss_hp = mv_boss_hp
        estimate = lt_cost[ nmax( val1 = 0 val2 = mv_boss_hp ) + 1 ] ) ).
    DATA lt_seen TYPE tt_seen.
    rv_mana = -1.
    " A* search: every queued state is at the start of a player turn.
    " For the same mana, boss and timers, cheaper paths with at least as much
    " health dominate. Their heuristic is equal, so they are popped first.
    WHILE lt_frontier IS NOT INITIAL AND rv_mana < 0.
      DATA(ls_state) = lt_frontier[ 1 ].
      DELETE lt_frontier INDEX 1.
      CHECK remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) = abap_true.
      rv_mana = COND #( WHEN ls_state-boss_hp <= 0 THEN ls_state-spent ELSE -1 ).
      CHECK rv_mana < 0.
      DATA(lt_next) = successors( is_state = ls_state iv_hard = iv_hard ).
      LOOP AT lt_next ASSIGNING FIELD-SYMBOL(<ls_next>).
        " All remaining ticks of an already-paid Poison are free damage.
        DATA(lv_remaining) = nmax( val1 = 0 val2 = <ls_next>-boss_hp - 3 * <ls_next>-poison ).
        <ls_next>-estimate = <ls_next>-spent + lt_cost[ lv_remaining + 1 ].
      ENDLOOP.
      INSERT LINES OF lt_next INTO TABLE lt_frontier.
    ENDWHILE.
  ENDMETHOD.

  METHOD remember_state.
    ASSIGN ct_seen[ mana = is_state-mana boss_hp = is_state-boss_hp
      shield = is_state-shield poison = is_state-poison recharge = is_state-recharge ] TO FIELD-SYMBOL(<ls_seen>).
    IF sy-subrc <> 0.
      INSERT is_state INTO TABLE ct_seen.
      rv_new = abap_true.
      RETURN.
    ENDIF.
    CHECK is_state-hit_points > <ls_seen>-hit_points.
    <ls_seen> = is_state.
    rv_new = abap_true.
  ENDMETHOD.

  METHOD get_result1.
    IF mv_result1 IS INITIAL.
      mv_result1 = |{ least_mana( ) }|.
    ENDIF.
    rv_result = mv_result1.
  ENDMETHOD.

  METHOD get_result2.
    IF mv_result2 IS INITIAL.
      mv_result2 = |{ least_mana( iv_hard = abap_true ) }|.
    ENDIF.
    rv_result = mv_result2.
  ENDMETHOD.
ENDCLASS.
