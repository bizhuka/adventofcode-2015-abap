CLASS ltc_password DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS examples FOR TESTING.
    METHODS forbidden_letters FOR TESTING.
    METHODS missing_straight FOR TESTING.
    METHODS distinct_pairs FOR TESTING.
    METHODS input_format FOR TESTING.
    METHODS carry_over FOR TESTING.
    METHODS puzzle_input FOR TESTING.
    METHODS result_methods FOR TESTING.
ENDCLASS.

CLASS ltc_password IMPLEMENTATION.
  METHOD examples.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( 'abcdefgh' ) exp = 'abcdffaa' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( 'ghijklmn' ) exp = 'ghjaabcc' ).
  ENDMETHOD.

  METHOD forbidden_letters.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'hijklmmn' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abcddioo' ) exp = abap_false ).
  ENDMETHOD.

  METHOD missing_straight.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abbceffg' ) exp = abap_false ).
  ENDMETHOD.

  METHOD distinct_pairs.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abbcegjk' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abcaaaaa' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abcdffaa' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'ghjaabcc' ) exp = abap_true ).
  ENDMETHOD.

  METHOD input_format.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abcddff' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'abcddffaa' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( 'Abcdffaa' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( '' ) exp = `` ).
    " A trailing newline is an extra character, even when a native regex accepts '$'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>is_valid( |abcdffaa{ cl_abap_char_utilities=>newline }| ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( |abcdffaa{ cl_abap_char_utilities=>newline }| ) exp = `` ).
  ENDMETHOD.

  METHOD carry_over.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( 'abcdffzz' ) exp = 'abcdggaa' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( 'zzzzzzzz' ) exp = 'aaaaabcc' ).
  ENDMETHOD.

  METHOD puzzle_input.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_a2015_11=>next_password( 'hepxcrrq' ) exp = 'hepxxyzz' ).
  ENDMETHOD.

  METHOD result_methods.
    DATA(lo_solver) = NEW zcl_a2015_11( ).
    lo_solver->init( VALUE #( ( `hepxcrrq` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_solver->get_result1( ) exp = 'hepxxyzz' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_solver->get_result2( ) exp = 'heqaabcc' ).
  ENDMETHOD.
ENDCLASS.
