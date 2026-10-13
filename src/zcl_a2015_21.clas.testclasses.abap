CLASS ltc_rpg DEFINITION DEFERRED.
CLASS zcl_a2015_21 DEFINITION LOCAL FRIENDS ltc_rpg.

CLASS ltc_rpg DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_21.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS player_attacks_first FOR TESTING.
    METHODS round_up_turns FOR TESTING.
    METHODS minimum_damage FOR TESTING.
    METHODS legal_loadouts FOR TESTING.
    METHODS puzzle_input FOR TESTING.
    METHODS line_endings FOR TESTING.
    METHODS repeat_and_reinitialize FOR TESTING.
ENDCLASS.

CLASS ltc_rpg IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD example.
    mo_cut->init( VALUE #( ( `Hit Points: 12` ) ( `Damage: 7` ) ( `Armor: 2` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 8 damage = 5 armor = 5 ) ) exp = abap_true ).
  ENDMETHOD.

  METHOD player_attacks_first.
    mo_cut->init( VALUE #( ( `Hit Points: 10` ) ( `Damage: 5` ) ( `Armor: 0` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 10 damage = 5 ) ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 5 damage = 5 ) ) exp = abap_false ).
  ENDMETHOD.

  METHOD round_up_turns.
    mo_cut->init( VALUE #( ( `Hit Points: 11` ) ( `Damage: 5` ) ( `Armor: 0` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 10 damage = 5 ) ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 11 damage = 5 ) ) exp = abap_true ).
  ENDMETHOD.

  METHOD minimum_damage.
    mo_cut->init( VALUE #( ( `Hit Points: 2` ) ( `Damage: 1` ) ( `Armor: 300` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 2 damage = 8 armor = 300 ) ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->player_wins( VALUE #( hit_points = 1 damage = 8 armor = 300 ) ) exp = abap_false ).
  ENDMETHOD.

  METHOD legal_loadouts.
    DATA(lt_loadouts) = mo_cut->get_loadouts( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_loadouts ) exp = 660 ).
    cl_abap_unit_assert=>assert_equals(
      act = xsdbool( line_exists( lt_loadouts[ cost = 8 damage = 4 armor = 0 ] ) ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = xsdbool( line_exists( lt_loadouts[ cost = 91 damage = 7 armor = 3 ] ) ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = xsdbool( line_exists( lt_loadouts[ cost = 158 damage = 9 armor = 0 ] ) ) exp = abap_true ).
    LOOP AT lt_loadouts ASSIGNING FIELD-SYMBOL(<ls_loadout>).
      cl_abap_unit_assert=>assert_equals(
        act = xsdbool( <ls_loadout>-damage >= 4 AND <ls_loadout>-damage <= 13
                      AND <ls_loadout>-armor <= 10 AND <ls_loadout>-cost <= 356 ) exp = abap_true ).
    ENDLOOP.
  ENDMETHOD.

  METHOD puzzle_input.
    mo_cut->init( VALUE #( ( `Hit Points: 100` ) ( `Damage: 8` ) ( `Armor: 2` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `91` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `158` ).
  ENDMETHOD.

  METHOD line_endings.
    mo_cut->init( VALUE #( ( |Hit Points: 100{ cl_abap_char_utilities=>newline }Damage: 8{ cl_abap_char_utilities=>newline }Armor: 2| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `91` ).
    mo_cut->init( VALUE #( ( |Hit Points: 100{ cl_abap_char_utilities=>cr_lf }Damage: 8{ cl_abap_char_utilities=>cr_lf }Armor: 2| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `158` ).
  ENDMETHOD.

  METHOD repeat_and_reinitialize.
    mo_cut->init( VALUE #( ( `Hit Points: 100` ) ( `Damage: 8` ) ( `Armor: 2` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `158` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `91` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `91` ).
    mo_cut->init( VALUE #( ( `` ) ( ` Hit Points: 1 ` ) ( `Damage: 1` ) ( ` Armor: 0 ` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `8` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `-1` ).
    mo_cut->init( VALUE #( ( `Hit Points: 1000` ) ( `Damage: 1000` ) ( `Armor: 1000` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `356` ).
  ENDMETHOD.
ENDCLASS.
