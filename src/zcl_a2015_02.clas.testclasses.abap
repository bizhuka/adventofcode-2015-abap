*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_02. "Class Under Test

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
    mo_cut->init( VALUE #( ( `2x3x4` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 58 ).

    mo_cut->init( VALUE #( ( `1x1x10` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 43 ).
  ENDMETHOD.

  METHOD test_2.
    mo_cut->init( VALUE #( ( `2x3x4` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 34 ).

    mo_cut->init( VALUE #( ( `1x1x10` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 14 ).
  ENDMETHOD.

ENDCLASS.
