*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_08.

    METHODS setup.
    METHODS empty_string FOR TESTING.
    METHODS simple_string FOR TESTING.
    METHODS escaped_quote FOR TESTING.
    METHODS hex_escaped FOR TESTING.
    METHODS escaped_backslash FOR TESTING.
    METHODS mixed_scenario FOR TESTING.
    METHODS total_difference FOR TESTING.

    METHODS part2_empty_string FOR TESTING.
    METHODS part2_simple_string FOR TESTING.
    METHODS part2_escaped_quote FOR TESTING.
    METHODS part2_hex_escaped FOR TESTING.
    METHODS part2_total_diff FOR TESTING.
ENDCLASS.

CLASS lcl_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

**********************************************************************
**********************************************************************

  METHOD empty_string.
    " "" -> Code: 2, Memory: 0, Diff: 2
    DATA(lv_input) = `""`.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_diff( lv_input )
      exp = 2 ).
  ENDMETHOD.

  METHOD simple_string.
    " "abc" -> Code: 5, Memory: 3, Diff: 2
    DATA(lv_input) = `"abc"`.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_diff( lv_input )
      exp = 2 ).
  ENDMETHOD.

  METHOD escaped_quote.
    " "aaa\"aaa" -> Code: 10, Memory: 7, Diff: 3
    DATA(lv_input) = `"aaa\"aaa"`.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_diff( lv_input )
      exp = 3 ).
  ENDMETHOD.

  METHOD hex_escaped.
    " "\x27" -> Code: 6, Memory: 1, Diff: 5
    DATA(lv_input) = `"\x27"`.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_diff( lv_input )
      exp = 5 ).
  ENDMETHOD.

  METHOD escaped_backslash.
    " "\\" -> Code: 4, Memory: 1, Diff: 3 ("\\")
    DATA(lv_input) = `"\\"` .
    cl_abap_unit_assert=>assert_equals(
        act = mo_cut->calculate_diff( lv_input )
        exp = 3 ).
  ENDMETHOD.

  METHOD mixed_scenario.
    " example combining multiple escapes
    DATA(lv_input) = `"a\"b\x27c\\d"`.
    " Code: 1 + 1 + 2 + 1 + 4 + 1 + 2 + 1 + 1 = 14 (bad math check: " + a + \" + b + \x27 + c + \\ + d + " )
    " length(`"a\"b\x27c\\d"`) = 14
    " Mem: a(1) + "(1) + b(1) + '(1) + c(1) + \(1) + d(1) = 7
    " Diff: 7
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_diff( lv_input )
      exp = 7 ).
  ENDMETHOD.

  METHOD total_difference.
    mo_cut->init( VALUE #(
      ( `""` )
      ( `"abc"` )
      ( `"aaa\"aaa"` )
      ( `"\x27"` )
    ) ).

    " Total Diff: 2 + 2 + 3 + 5 = 12
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 12 ).
  ENDMETHOD.

**********************************************************************
**********************************************************************


  METHOD part2_empty_string.
    " "" -> "\"\"" (Length diff: 4)
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_encoded_diff( `""` )
      exp = 4 ).
  ENDMETHOD.

  METHOD part2_simple_string.
    " "abc" -> "\"abc\"" (Length diff: 4)
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_encoded_diff( `"abc"` )
      exp = 4 ).
  ENDMETHOD.

  METHOD part2_escaped_quote.
    " "aaa\"aaa" -> "\"aaa\\\"aaa\"" (Length diff: 6)
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_encoded_diff( `"aaa\"aaa"` )
      exp = 6 ).
  ENDMETHOD.

  METHOD part2_hex_escaped.
    " "\x27" -> "\"\\x27\"" (Length diff: 5)
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate_encoded_diff( `"\x27"` )
      exp = 5 ).
  ENDMETHOD.

  METHOD part2_total_diff.
    " Integration test for get_result2 with examplar data
    DATA(lt_input) = VALUE string_table(
      ( `""` )
      ( `"abc"` )
      ( `"aaa\"aaa"` )
      ( `"\x27"` )
    ).

    mo_cut->init( lt_input ).

    " Total Diff: 4 + 4 + 6 + 5 = 19
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 19 ).
  ENDMETHOD.

ENDCLASS.
