*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_07. "Class Under Test

    METHODS:
      setup,

      "Test methods
      test_1 FOR TESTING,
      test_2 FOR TESTING.
ENDCLASS.


CLASS lcl_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_1.
    mo_cut->init( VALUE #(
                    ( `123 -> x` )
                    ( `456 -> y` )
                    ( `x AND y -> d` )
                    ( `x OR y -> e` )
                    ( `x LSHIFT 2 -> f` )
                    ( `y RSHIFT 2 -> g` )
                    ( `NOT x -> h` )
                    ( `NOT y -> a` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 65079 ).
  ENDMETHOD.

  METHOD test_2.
    " Regression: the Part 1 result must form a valid instruction when overriding b.
    " With a = b << 1, Part 1 yields 2; overriding b with 2 makes Part 2 yield 4.
    mo_cut->init( VALUE #(
                    ( `1 -> b` )
                    ( `b LSHIFT 1 -> a` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 4 ).
  ENDMETHOD.

ENDCLASS.
