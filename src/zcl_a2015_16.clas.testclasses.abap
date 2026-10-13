CLASS ltc_aunt_sue DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_16.
    METHODS setup.
    METHODS all_properties FOR TESTING.
    METHODS mismatch_then_match FOR TESTING.
    METHODS missing_properties FOR TESTING.
    METHODS zero_values FOR TESTING.
    METHODS no_match FOR TESTING.
    METHODS empty_input FOR TESTING.
    METHODS reinitialize FOR TESTING.
    METHODS part2_ranges FOR TESTING.
    METHODS part2_boundaries FOR TESTING.
    METHODS part2_exact_values FOR TESTING.
    METHODS part2_reinitialize FOR TESTING.
ENDCLASS.

CLASS ltc_aunt_sue IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD all_properties.
    mo_cut->init( VALUE #( ( `Sue 42: children: 3, cats: 7, samoyeds: 2, pomeranians: 3, akitas: 0, vizslas: 0, goldfish: 5, trees: 3, cars: 2, perfumes: 1` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `42` ).
  ENDMETHOD.

  METHOD mismatch_then_match.
    mo_cut->init( VALUE #(
      ( `Sue 99: children: 3, cats: 8, cars: 2` )
      ( `Sue 17: cars: 2, perfumes: 1, children: 3` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `17` ).
  ENDMETHOD.

  METHOD missing_properties.
    mo_cut->init( VALUE #( ( `Sue 500: perfumes: 1` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `500` ).
  ENDMETHOD.

  METHOD zero_values.
    mo_cut->init( VALUE #(
      ( `Sue 1: akitas: 1, vizslas: 0` )
      ( `Sue 2: vizslas: 0, akitas: 0` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
  ENDMETHOD.

  METHOD no_match.
    mo_cut->init( VALUE #(
      ( `Sue 3: goldfish: 4, pomeranians: 3` )
      ( `Sue 4: trees: 4, samoyeds: 2` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `` ).
  ENDMETHOD.

  METHOD empty_input.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `` ).
  ENDMETHOD.

  METHOD reinitialize.
    mo_cut->init( VALUE #( ( `Sue 7: cats: 7` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `7` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `7` ).
    mo_cut->init( VALUE #( ( `Sue 8: cats: 6` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `` ).
    mo_cut->init( VALUE #( ( `Sue 9: cars: 2` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `9` ).
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `` ).
  ENDMETHOD.
  METHOD part2_ranges.
    mo_cut->init( VALUE #(
      ( `Sue 11: cats: 7, trees: 3, pomeranians: 3, goldfish: 5` )
      ( `Sue 23: cats: 8, trees: 4, pomeranians: 2, goldfish: 4` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `23` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `11` ).
    mo_cut->init( VALUE #(
      ( `Sue 23: cats: 8, trees: 4, pomeranians: 2, goldfish: 4` )
      ( `Sue 11: cats: 7, trees: 3, pomeranians: 3, goldfish: 5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `11` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `23` ).
  ENDMETHOD.

  METHOD part2_boundaries.
    DATA(lt_rejected) = VALUE string_table(
      ( `Sue 1: cats: 7` ) ( `Sue 1: cats: 6` )
      ( `Sue 1: trees: 3` ) ( `Sue 1: trees: 2` )
      ( `Sue 1: pomeranians: 3` ) ( `Sue 1: pomeranians: 4` )
      ( `Sue 1: goldfish: 5` ) ( `Sue 1: goldfish: 6` ) ).
    LOOP AT lt_rejected INTO DATA(lv_line).
      mo_cut->init( VALUE #( ( lv_line ) ) ).
      cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `` msg = lv_line ).
    ENDLOOP.
    mo_cut->init( VALUE #( ( `Sue 5: goldfish: 0, pomeranians: 0` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `5` ).
  ENDMETHOD.

  METHOD part2_exact_values.
    mo_cut->init( VALUE #( ( `Sue 31: children: 3, samoyeds: 2, akitas: 0, vizslas: 0, cars: 2, perfumes: 1` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `31` ).
    DATA(lt_rejected) = VALUE string_table(
      ( `Sue 1: children: 4` ) ( `Sue 1: samoyeds: 1` )
      ( `Sue 1: akitas: 1` ) ( `Sue 1: vizslas: 1` )
      ( `Sue 1: cars: 3` ) ( `Sue 1: perfumes: 0` ) ).
    LOOP AT lt_rejected INTO DATA(lv_line).
      mo_cut->init( VALUE #( ( lv_line ) ) ).
      cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `` msg = lv_line ).
    ENDLOOP.
  ENDMETHOD.

  METHOD part2_reinitialize.
    mo_cut->init( VALUE #( ( `Sue 41: cats: 8` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `41` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `41` ).
    mo_cut->init( VALUE #( ( `Sue 42: cats: 7` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `` ).
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `` ).
  ENDMETHOD.
ENDCLASS.
