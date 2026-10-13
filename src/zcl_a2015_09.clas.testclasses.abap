*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_09.

    METHODS setup.
    METHODS test_1 FOR TESTING.
    METHODS test_2 FOR TESTING.
    METHODS sparse_and_directional FOR TESTING.
    METHODS empty_and_zero FOR TESTING.
ENDCLASS.

CLASS lcl_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_1.
    " "" -> Code: 2, Memory: 0, Diff: 2
    mo_cut->init( VALUE #(
      ( `London to Dublin = 464` )
      ( `London to Belfast = 518` )
      ( `Dublin to Belfast = 141` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 605 ).
  ENDMETHOD.

  METHOD test_2.
    " "" -> Code: 2, Memory: 0, Diff: 2
    mo_cut->init( VALUE #(
      ( `London to Dublin = 464` )
      ( `London to Belfast = 518` )
      ( `Dublin to Belfast = 141` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 982 ).
  ENDMETHOD.

  METHOD sparse_and_directional.
    " Missing edges invalidate a route; an explicitly supplied direction takes priority.
    mo_cut->init( VALUE #( ( `A to B = 4` ) ( `B to C = 6` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 10 ).
    mo_cut->init( VALUE #( ( `A to B = 5` ) ( `B to A = 7` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 7 ).
  ENDMETHOD.

  METHOD empty_and_zero.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 0 ).
    mo_cut->init( VALUE #( ( `A to B = 0` ) ( `B to C = 4` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 4 ).
  ENDMETHOD.
ENDCLASS.
