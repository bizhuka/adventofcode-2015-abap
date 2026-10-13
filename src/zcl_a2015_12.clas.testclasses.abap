"! @testing zcl_a2015_12
CLASS ltcl_test DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_12.
    METHODS:
      setup,
      test_part1 FOR TESTING,
      test_part2 FOR TESTING.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_part1.
    mo_cut->init( VALUE #( ( `[1,2,3]` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 6 act = mo_cut->get_result1( ) msg = 'Failed for [1,2,3]' ).

    mo_cut->init( VALUE #( ( `{"a":2,"b":4}` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 6 act = mo_cut->get_result1( ) msg = 'Failed for {"a":2,"b":4}' ).

    mo_cut->init( VALUE #( ( `[[[3]]]` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = mo_cut->get_result1( ) msg = 'Failed for [[[3]]]' ).

    mo_cut->init( VALUE #( ( `{"a":{"b":4},"c":-1}` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = mo_cut->get_result1( ) msg = 'Failed for {"a":{"b":4},"c":-1}' ).
  ENDMETHOD.

  METHOD test_part2.
    mo_cut->init( VALUE #( ( `[1,2,3]` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 6 act = mo_cut->get_result2( ) msg = 'Failed for [1,2,3]' ).

    mo_cut->init( VALUE #( ( `[1,{"c":"red","b":2},3]` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = mo_cut->get_result2( ) msg = 'Failed for [1,{"c":"red","b":2},3]' ).

    mo_cut->init( VALUE #( ( `{"d":"red","e":[1,2,3,4],"f":5}` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = mo_cut->get_result2( ) msg = 'Failed for {"d":"red","e":[1,2,3,4],"f":5}' ).

    mo_cut->init( VALUE #( ( `[1,"red",5]` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 6 act = mo_cut->get_result2( ) msg = 'Failed for [1,"red",5]' ).
  ENDMETHOD.
ENDCLASS.
