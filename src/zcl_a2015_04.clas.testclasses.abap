*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_04. "Class Under Test

    METHODS:
      setup,

      "Test methods
      test_1 FOR TESTING,
      test_2 FOR TESTING,
      test_real_part2 FOR TESTING.
ENDCLASS.


CLASS lcl_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_1.
    mo_cut->init( VALUE #( ( `abcdef` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 609043 ).

    mo_cut->init( VALUE #( ( `pqrstuv` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1048970 ).
  ENDMETHOD.

  METHOD test_2.
    " MD5(key + '1') = 0000007ca44a1c014ffb91cd3c6d538f.
    " Both parts must include candidate 1, including when Part 1 is already cached.
    mo_cut->init( VALUE #( ( `abap-test-14755889` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 1 ).

    " Part 2 must also work without a preceding Part 1 call.
    DATA(lo_reverse) = NEW zcl_a2015_04( ).
    lo_reverse->init( VALUE #( ( `abap-test-14755889` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_reverse->get_result2( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_reverse->get_result1( ) exp = 1 ).
  ENDMETHOD.

  METHOD test_real_part2.
    " Exercise the search beyond the cached Part 1 answer, not just a shared answer.
    mo_cut->init( VALUE #( ( `abcdef` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 609043 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 6742839 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 609043 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 6742839 ).

    " A new input must invalidate both cached answers, including the six-zero result.
    mo_cut->init( VALUE #( ( `abap-test-14755889` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = 1 ).

    " Starting with Part 2 on the longer fixture must still find the first answer.
    DATA(lo_reverse) = NEW zcl_a2015_04( ).
    lo_reverse->init( VALUE #( ( `abcdef` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_reverse->get_result2( ) exp = 6742839 ).
    cl_abap_unit_assert=>assert_equals( act = lo_reverse->get_result1( ) exp = 609043 ).
  ENDMETHOD.

ENDCLASS.
