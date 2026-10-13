*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_06. "Class Under Test

    METHODS:
      setup,

      "Test methods
      test_1 FOR TESTING,
      test_2 FOR TESTING,
      test_rectangles FOR TESTING,
      test_brightness_floor FOR TESTING,
      test_high_brightness FOR TESTING,
      test_weighted_cells FOR TESTING,
      test_invalid_and_empty FOR TESTING.
ENDCLASS.


CLASS lcl_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_1.
    mo_cut->init( VALUE #( ( `turn on 0,0 through 999,999` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1000 * 1000 ).

    mo_cut->init( VALUE #( ( `toggle 0,0 through 999,0` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1000 ).

    mo_cut->init( VALUE #( ( `turn on 0,0 through 999,999` )
                           ( `turn off 499,499 through 500,500` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1000 * 1000 - 4 ).
  ENDMETHOD.

  METHOD test_2.
    mo_cut->init( VALUE #( ( `turn on 0,0 through 0,0` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `turn off 0,0 through 0,0` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 0 ).

    mo_cut->init( VALUE #( ( `toggle 0,0 through 999,999` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 2000000 ).
  ENDMETHOD.

  METHOD test_rectangles.
    " Non-square rectangles at the end of a row must not spill into adjacent rows.
    mo_cut->init( VALUE #( ( `turn on 998,0 through 999,1` )
                           ( `toggle 999,1 through 999,2` )
                           ( `turn on 0,999 through 0,999` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 9 ).
  ENDMETHOD.

  METHOD test_high_brightness.
    " Brightness must exceed a byte without wrapping, even when a lamp is toggled repeatedly.
    mo_cut->init( VALUE #( FOR i = 1 UNTIL i > 300 ( `toggle 0,0 through 0,0` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 600 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 0 ).
  ENDMETHOD.

  METHOD test_invalid_and_empty.
    mo_cut->init( VALUE #( ( `ignore this line` ) ( `turn on 999,999 through 999,999` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 1 ).
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 0 ).
  ENDMETHOD.

  METHOD test_brightness_floor.
    " Overlapping turn-off instructions cannot make brightness negative.
    mo_cut->init( VALUE #( ( `turn on 2,3 through 4,4` )
                           ( `turn off 2,3 through 4,4` )
                           ( `turn off 2,3 through 4,4` )
                           ( `toggle 3,4 through 5,4` )
                           ( `turn off 4,4 through 6,4` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 4 ).
  ENDMETHOD.

  METHOD test_weighted_cells.
    " Nonuniform boundary gaps need area weighting, including untouched gaps.
    mo_cut->init( VALUE #( ( `turn on 100,200 through 199,299` )
                           ( `toggle 150,250 through 249,349` )
                           ( `turn off 180,280 through 189,289` )
                           ( `turn on 900,900 through 999,999` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 25000 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 39900 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 25000 ).
  ENDMETHOD.

ENDCLASS.
