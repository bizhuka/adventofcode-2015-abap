*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING DURATION LONG RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_a2015_05. "Class Under Test

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
    mo_cut->init( VALUE #( ( `ugknbfddgicrmopn` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `aaa` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `jchzalrnumimnmhp` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 0 ).

    mo_cut->init( VALUE #( ( `haegwjzuvuyypxyu` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 0 ).

    mo_cut->init( VALUE #( ( `dvszwmarrgswjxmb` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result1( )
      exp = 0 ).
  ENDMETHOD.

  METHOD test_2.
    mo_cut->init( VALUE #( ( `qjhvhtzxzqqjkmpb` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `xxyxx` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 1 ).

    mo_cut->init( VALUE #( ( `uurcxstgmygtbstg` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 0 ).

    mo_cut->init( VALUE #( ( `ieodomkazucvgmuy` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_result2( )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
