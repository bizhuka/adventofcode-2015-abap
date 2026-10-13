*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_03. "Class Under Test

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
    mo_cut->init( VALUE #( ( `>` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 2 ).

    mo_cut->init( VALUE #( ( `^>v<` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 4 ).

    mo_cut->init( VALUE #( ( `^v^v^v^v^v` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 2 ).
  ENDMETHOD.

  METHOD test_2.
    " Odd-length inputs must execute the final move without reading past the string.
    mo_cut->init( VALUE #( ( `>` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 2 ).

    mo_cut->init( VALUE #( ( `^v` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 3 ).

    mo_cut->init( VALUE #( ( `^>v<` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 3 ).

    mo_cut->init( VALUE #( ( `^v^v^v^v^v` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 11 ).
  ENDMETHOD.

ENDCLASS.
