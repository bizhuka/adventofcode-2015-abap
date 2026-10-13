CLASS zcl_a2015_21 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_fighter,
             hit_points TYPE i,
             damage TYPE i,
             armor TYPE i,
           END OF ty_fighter,
           BEGIN OF ty_item,
             cost TYPE i,
             damage TYPE i,
             armor TYPE i,
           END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    DATA ms_boss TYPE ty_fighter.
    DATA mv_solved TYPE abap_bool.
    DATA mv_result1 TYPE i.
    DATA mv_result2 TYPE i.
    METHODS get_loadouts RETURNING VALUE(rt_loadouts) TYPE tt_items.
    METHODS player_wins
      IMPORTING is_player TYPE ty_fighter
      RETURNING VALUE(rv_wins) TYPE abap_bool.
    METHODS solve.
ENDCLASS.

CLASS zcl_a2015_21 IMPLEMENTATION.
  METHOD init.
    CLEAR: ms_boss, mv_solved, mv_result1, mv_result2.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = condense( <lv_line> ).
      CHECK lv_line IS NOT INITIAL.
      SPLIT <lv_line> AT ':' INTO DATA(lv_name) DATA(lv_value).
      DATA(lv_amount) = CONV i( condense( lv_value ) ).
      CASE condense( lv_name ).
        WHEN 'Hit Points'. ms_boss-hit_points = lv_amount.
        WHEN 'Damage'. ms_boss-damage = lv_amount.
        WHEN 'Armor'. ms_boss-armor = lv_amount.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_loadouts.
    DATA(lt_weapons) = VALUE tt_items(
      ( cost = 8 damage = 4 ) ( cost = 10 damage = 5 )
      ( cost = 25 damage = 6 ) ( cost = 40 damage = 7 ) ( cost = 74 damage = 8 ) ).
    DATA(lt_armor) = VALUE tt_items(
      ( ) ( cost = 13 armor = 1 ) ( cost = 31 armor = 2 )
      ( cost = 53 armor = 3 ) ( cost = 75 armor = 4 ) ( cost = 102 armor = 5 ) ).
    DATA(lt_rings) = VALUE tt_items(
      ( cost = 25 damage = 1 ) ( cost = 50 damage = 2 ) ( cost = 100 damage = 3 )
      ( cost = 20 armor = 1 ) ( cost = 40 armor = 2 ) ( cost = 80 armor = 3 ) ).

    " One empty choice, six single rings and fifteen distinct pairs.
    DATA(lt_ring_choices) = VALUE tt_items( ( ) ).
    APPEND LINES OF lt_rings TO lt_ring_choices.
    LOOP AT lt_rings ASSIGNING FIELD-SYMBOL(<ls_first>).
      DATA(lv_next) = sy-tabix + 1.
      LOOP AT lt_rings ASSIGNING FIELD-SYMBOL(<ls_second>) FROM lv_next.
        APPEND VALUE #( cost = <ls_first>-cost + <ls_second>-cost
                        damage = <ls_first>-damage + <ls_second>-damage
                        armor = <ls_first>-armor + <ls_second>-armor ) TO lt_ring_choices.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_weapons ASSIGNING FIELD-SYMBOL(<ls_weapon>).
      LOOP AT lt_armor ASSIGNING FIELD-SYMBOL(<ls_armor>).
        LOOP AT lt_ring_choices ASSIGNING FIELD-SYMBOL(<ls_rings>).
          APPEND VALUE #( cost = <ls_weapon>-cost + <ls_armor>-cost + <ls_rings>-cost
                          damage = <ls_weapon>-damage + <ls_rings>-damage
                          armor = <ls_armor>-armor + <ls_rings>-armor ) TO rt_loadouts.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD player_wins.
    DATA(lv_player_damage) = nmax( val1 = 1 val2 = is_player-damage - ms_boss-armor ).
    DATA(lv_boss_damage) = nmax( val1 = 1 val2 = ms_boss-damage - is_player-armor ).
    DATA(lv_player_turns) = ( ms_boss-hit_points + lv_player_damage - 1 ) DIV lv_player_damage.
    DATA(lv_boss_turns) = ( is_player-hit_points + lv_boss_damage - 1 ) DIV lv_boss_damage.
    " Equal turn counts favor the player, who attacks first.
    rv_wins = xsdbool( lv_player_turns <= lv_boss_turns ).
  ENDMETHOD.

  METHOD solve.
    CHECK mv_solved = abap_false.
    " -1 means that no loadout has the requested outcome.
    mv_result1 = -1.
    mv_result2 = -1.
    DATA(lt_loadouts) = get_loadouts( ).
    LOOP AT lt_loadouts ASSIGNING FIELD-SYMBOL(<ls_loadout>).
      DATA(lv_wins) = player_wins( VALUE #( hit_points = 100 damage = <ls_loadout>-damage armor = <ls_loadout>-armor ) ).
      mv_result1 = COND #( WHEN lv_wins = abap_true AND ( mv_result1 < 0 OR <ls_loadout>-cost < mv_result1 )
                          THEN <ls_loadout>-cost ELSE mv_result1 ).
      mv_result2 = COND #( WHEN lv_wins = abap_false THEN nmax( val1 = mv_result2 val2 = <ls_loadout>-cost )
                          ELSE mv_result2 ).
    ENDLOOP.
    mv_solved = abap_true.
  ENDMETHOD.

  METHOD get_result1.
    solve( ).
    rv_result = |{ mv_result1 }|.
  ENDMETHOD.

  METHOD get_result2.
    solve( ).
    rv_result = |{ mv_result2 }|.
  ENDMETHOD.
ENDCLASS.
