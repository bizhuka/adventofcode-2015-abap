*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_10.

    METHODS setup.
    METHODS test_1 FOR TESTING.
    METHODS test_2 FOR TESTING.
    METHODS long_chunks FOR TESTING.
ENDCLASS.

CLASS lcl_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_1.
    mo_cut->init( VALUE #( ( `211` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 1 )
      exp = strlen( `1221` ) ).

    mo_cut->init( VALUE #( ( `1` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 1 )
      exp = strlen( `11` ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 2 )
      exp = strlen( `21` ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 3 )
      exp = strlen( `1211` ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 4 )
      exp = strlen( `111221` ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->look_and_say_length( 5 )
      exp = strlen( `312211` ) ).
  ENDMETHOD.

  METHOD test_2.
    " Run counts can contain multiple digits; empty and zero-step inputs must stay valid.
    mo_cut->init( VALUE #( ( `111111111111` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 1 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 2 ) exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 0 ) exp = 12 ).
    mo_cut->init( VALUE #( ( `` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 10 ) exp = 0 ).
  ENDMETHOD.

  METHOD long_chunks.
    mo_cut->init( VALUE #( ( repeat( val = `12` occ = 3000 ) ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 1 ) exp = 12000 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->look_and_say_length( 2 ) exp = 12000 ).
  ENDMETHOD.
ENDCLASS.
