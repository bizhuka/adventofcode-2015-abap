*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_01. "Class Under Test

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
    mo_cut->init( VALUE #( ( `)())())` ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = -3 ).
  ENDMETHOD.

  METHOD test_2.
    mo_cut->init( VALUE #( ( `)` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `()())` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
