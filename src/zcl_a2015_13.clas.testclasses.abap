CLASS ltc_seating DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_13.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS with_self FOR TESTING.
    METHODS negative_total FOR TESTING.
    METHODS reinitialize FOR TESTING.
    METHODS empty_input FOR TESTING.
ENDCLASS.

CLASS ltc_seating IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
    mo_cut->init( VALUE #(
      ( `Alice would gain 54 happiness units by sitting next to Bob.` )
      ( `Alice would lose 79 happiness units by sitting next to Carol.` )
      ( `Alice would lose 2 happiness units by sitting next to David.` )
      ( `Bob would gain 83 happiness units by sitting next to Alice.` )
      ( `Bob would lose 7 happiness units by sitting next to Carol.` )
      ( `Bob would lose 63 happiness units by sitting next to David.` )
      ( `Carol would lose 62 happiness units by sitting next to Alice.` )
      ( `Carol would gain 60 happiness units by sitting next to Bob.` )
      ( `Carol would gain 55 happiness units by sitting next to David.` )
      ( `David would gain 46 happiness units by sitting next to Alice.` )
      ( `David would lose 7 happiness units by sitting next to Bob.` )
      ( `David would gain 41 happiness units by sitting next to Carol.` ) ) ).
  ENDMETHOD.

  METHOD example.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `330` ).
  ENDMETHOD.

  METHOD with_self.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `286` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `286` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `330` ).
  ENDMETHOD.

  METHOD negative_total.
    mo_cut->init( VALUE #(
      ( `Alice would lose 1 happiness units by sitting next to Bob.` )
      ( `Alice would lose 2 happiness units by sitting next to Carol.` )
      ( `Bob would lose 3 happiness units by sitting next to Alice.` )
      ( `Bob would lose 4 happiness units by sitting next to Carol.` )
      ( `Carol would lose 5 happiness units by sitting next to Alice.` )
      ( `Carol would lose 6 happiness units by sitting next to Bob.` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-21` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `-11` ).
  ENDMETHOD.

  METHOD reinitialize.
    mo_cut->init( VALUE #(
      ( `` )
      ( `Carol would gain 3 happiness units by sitting next to Bob.` )
      ( `Bob would gain 4 happiness units by sitting next to Alice.` )
      ( `Alice would gain 5 happiness units by sitting next to Carol.` )
      ( `Carol would gain 6 happiness units by sitting next to Alice.` )
      ( `Bob would gain 7 happiness units by sitting next to Carol.` )
      ( `Alice would gain 8 happiness units by sitting next to Bob.` )
      ( `` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `33` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `23` ).
  ENDMETHOD.

  METHOD empty_input.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.
ENDCLASS.
