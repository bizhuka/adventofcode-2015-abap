CLASS lcl_output DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun_out.
    DATA text TYPE string.
ENDCLASS.
CLASS lcl_output IMPLEMENTATION.
  METHOD if_oo_adt_classrun_out~write.
    text = text && CONV string( data ) && `;`.
    output = me.
  ENDMETHOD.
  METHOD if_oo_adt_classrun_out~get.
    IF data IS SUPPLIED.
      if_oo_adt_classrun_out~write( data = data ).
    ENDIF.
    output = text.
    CLEAR text.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_race DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_14.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS cycle_boundaries FOR TESTING.
    METHODS ties_and_repeat FOR TESTING.
    METHODS reinitialize FOR TESTING.
    METHODS empty_and_zero FOR TESTING.
    METHODS puzzle_run FOR TESTING.
ENDCLASS.
CLASS ltc_race IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
    mo_cut->init( VALUE #(
      ( `Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.` )
      ( `Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.` ) ) ).
  ENDMETHOD.
  METHOD example.
    mo_cut->mv_seconds = 1000.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1120` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `689` ).
  ENDMETHOD.
  METHOD cycle_boundaries.
    mo_cut->init( VALUE #( ( `Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.` ) ) ).
    mo_cut->mv_seconds = 10.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `140` ).
    mo_cut->mv_seconds = 11.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `140` ).
    mo_cut->mv_seconds = 137.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `140` ).
    mo_cut->mv_seconds = 138.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `154` ).
  ENDMETHOD.
  METHOD ties_and_repeat.
    mo_cut->init( VALUE #(
      ( `Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.` )
      ( `Dancer can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.` ) ) ).
    mo_cut->mv_seconds = 20.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `20` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `20` ).
  ENDMETHOD.
  METHOD reinitialize.
    mo_cut->init( VALUE #( ( `Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2660` ).
  ENDMETHOD.
  METHOD empty_and_zero.
    mo_cut->mv_seconds = 0.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
    mo_cut->init( VALUE #( ) ).
    mo_cut->mv_seconds = 2503.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.
  METHOD puzzle_run.
    DATA(lo_output) = NEW lcl_output( ).
    mo_cut->if_oo_adt_classrun~main( lo_output ).
    cl_abap_unit_assert=>assert_equals( act = lo_output->text exp = `Result1 = 2640;Result2 = 1102;` ).
  ENDMETHOD.
ENDCLASS.
