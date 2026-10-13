CLASS ltc_wizard DEFINITION DEFERRED.
CLASS zcl_a2015_22 DEFINITION LOCAL FRIENDS ltc_wizard.

CLASS ltc_wizard DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_22.
    METHODS setup.
    METHODS examples FOR TESTING.
    METHODS effects_and_expiration FOR TESTING.
    METHODS active_effect_recast FOR TESTING.
    METHODS shield_and_minimum_damage FOR TESTING.
    METHODS poison_prevents_attack FOR TESTING.
    METHODS exact_mana_and_instant_kill FOR TESTING.
    METHODS recharge_before_cast FOR TESTING.
    METHODS hard_mode_before_effects FOR TESTING.
    METHODS puzzle_input FOR TESTING.
    METHODS reinitialize_and_line_endings FOR TESTING.
    METHODS health_dominance FOR TESTING.
ENDCLASS.

CLASS ltc_wizard IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
    mo_cut->init( VALUE #( ( `Hit Points: 55` ) ( `Damage: 8` ) ) ).
  ENDMETHOD.

  METHOD health_dominance.
    DATA lt_seen TYPE zcl_a2015_22=>tt_seen.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 10 mana = 100 boss_hp = 20 spent = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) exp = abap_true ).
    ls_state-hit_points = 9.
    ls_state-spent = 153.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) exp = abap_false ).
    ls_state-hit_points = 10.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) exp = abap_false ).
    ls_state-hit_points = 11.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) exp = abap_true ).
    ls_state-hit_points = 1.
    ls_state-mana = 101.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remember_state( EXPORTING is_state = ls_state CHANGING ct_seen = lt_seen ) exp = abap_true ).
  ENDMETHOD.

  METHOD examples.
    mo_cut->init( VALUE #( ( `Hit Points: 13` ) ( `Damage: 8` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->least_mana( iv_hit_points = 10 iv_mana = 250 ) exp = 226 ).
    mo_cut->init( VALUE #( ( `Hit Points: 14` ) ( `Damage: 8` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->least_mana( iv_hit_points = 10 iv_mana = 250 ) exp = 641 ).
  ENDMETHOD.

  METHOD effects_and_expiration.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( boss_hp = 10 mana = 0 shield = 1 poison = 1 recharge = 1 ).
    mo_cut->apply_effects( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-boss_hp exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-mana exp = 101 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-shield exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-poison exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-recharge exp = 0 ).
    mo_cut->apply_effects( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-boss_hp exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-mana exp = 101 ).
  ENDMETHOD.

  METHOD active_effect_recast.
    DO 3 TIMES.
      DATA(lv_spell) = sy-index + 2.
      DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( mana = 500 shield = 1 poison = 1 recharge = 1 ).
      cl_abap_unit_assert=>assert_equals(
        act = mo_cut->cast_spell( EXPORTING iv_spell = lv_spell CHANGING cs_state = ls_state ) exp = abap_false ).
      cl_abap_unit_assert=>assert_equals( act = ls_state-mana exp = 500 ).
      mo_cut->apply_effects( CHANGING cs_state = ls_state ).
      cl_abap_unit_assert=>assert_equals(
        act = mo_cut->cast_spell( EXPORTING iv_spell = lv_spell CHANGING cs_state = ls_state ) exp = abap_true ).
    ENDDO.
  ENDMETHOD.

  METHOD shield_and_minimum_damage.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 20 boss_hp = 10 shield = 1 ).
    mo_cut->boss_turn( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-hit_points exp = 12 ).
    ls_state = VALUE #( hit_points = 20 boss_hp = 10 shield = 2 ).
    mo_cut->boss_turn( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-hit_points exp = 19 ).
    mo_cut->mv_boss_damage = 1.
    ls_state = VALUE #( hit_points = 20 boss_hp = 10 shield = 2 ).
    mo_cut->boss_turn( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-hit_points exp = 19 ).
  ENDMETHOD.

  METHOD poison_prevents_attack.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 1 boss_hp = 3 poison = 1 ).
    mo_cut->boss_turn( CHANGING cs_state = ls_state ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-hit_points exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-boss_hp exp = 0 ).
    ls_state = VALUE #( hit_points = 1 boss_hp = 3 poison = 1 spent = 173 ).
    DATA(lt_next) = mo_cut->successors( is_state = ls_state iv_hard = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_next ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_next[ 1 ]-spent exp = 173 ).
  ENDMETHOD.

  METHOD exact_mana_and_instant_kill.
    mo_cut->init( VALUE #( ( `Hit Points: 4` ) ( `Damage: 100` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->least_mana( iv_hit_points = 1 iv_mana = 53 ) exp = 53 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->least_mana( iv_hit_points = 1 iv_mana = 52 ) exp = -1 ).
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 1 mana = 73 boss_hp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cast_spell( EXPORTING iv_spell = 2 CHANGING cs_state = ls_state ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-hit_points exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-mana exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_state-spent exp = 73 ).
  ENDMETHOD.

  METHOD recharge_before_cast.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 10 boss_hp = 4 recharge = 1 ).
    DATA(lt_next) = mo_cut->successors( is_state = ls_state iv_hard = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = xsdbool( line_exists( lt_next[ boss_hp = 0 mana = 48 spent = 53 ] ) ) exp = abap_true ).
  ENDMETHOD.

  METHOD hard_mode_before_effects.
    DATA(ls_state) = VALUE zcl_a2015_22=>ty_state( hit_points = 1 boss_hp = 3 poison = 1 mana = 500 ).
    DATA(lt_next) = mo_cut->successors( is_state = ls_state iv_hard = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_next ) exp = 0 ).
    ls_state-hit_points = 2.
    lt_next = mo_cut->successors( is_state = ls_state iv_hard = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_next ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_next[ 1 ]-hit_points exp = 1 ).
  ENDMETHOD.

  METHOD puzzle_input.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `953` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1289` ).
  ENDMETHOD.

  METHOD reinitialize_and_line_endings.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `953` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `953` ).
    mo_cut->init( VALUE #( ( |Hit Points: 4{ cl_abap_char_utilities=>newline }Damage: 8| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `53` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `53` ).
    mo_cut->init( VALUE #( ( |Hit Points: 55{ cl_abap_char_utilities=>cr_lf }Damage: 8| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `953` ).
  ENDMETHOD.
ENDCLASS.
