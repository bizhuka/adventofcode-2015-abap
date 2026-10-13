CLASS ltc_test DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_15.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS negative_total FOR TESTING.
    METHODS zero_amount FOR TESTING.
    METHODS single_and_reinitialize FOR TESTING.
    METHODS empty_input FOR TESTING.
    METHODS puzzle_run FOR TESTING.
ENDCLASS.

CLASS ltc_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
    mo_cut->init( VALUE #(
      ( `Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8` )
      ( `Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3` ) ) ).
  ENDMETHOD.
  METHOD example.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `57600000` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `62842880` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `62842880` ).
  ENDMETHOD.
  METHOD negative_total.
    mo_cut->init( VALUE #( ( `Bad: capacity -1, durability -1, flavor 1, texture 1, calories 5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.
  METHOD zero_amount.
    mo_cut->init( VALUE #(
      ( `Bad: capacity -1, durability -1, flavor -1, texture -1, calories 5` )
      ( `Good: capacity 1, durability 1, flavor 1, texture 1, calories 5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `100000000` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `100000000` ).
  ENDMETHOD.
  METHOD single_and_reinitialize.
    DATA(lv_previous) = mo_cut->get_result1( ).
    mo_cut->init( VALUE #( ( `Good: capacity 2, durability 2, flavor 2, texture 2, calories 4` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1600000000` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.
  METHOD empty_input.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.
  METHOD puzzle_run.
    DATA(lo_output) = NEW lcl_output( ).
    mo_cut->if_oo_adt_classrun~main( lo_output ).
    cl_abap_unit_assert=>assert_equals( act = lo_output->text exp = `Result1 = 21367368;Result2 = 1766400;` ).
  ENDMETHOD.
ENDCLASS.
