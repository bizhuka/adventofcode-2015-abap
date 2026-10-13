CLASS ltc_containers DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_17.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS duplicate_containers FOR TESTING.
    METHODS default_150_liters FOR TESTING.
    METHODS no_container_reuse FOR TESTING.
    METHODS no_solution FOR TESTING.
    METHODS reinitialize FOR TESTING.
    METHODS blank_lines FOR TESTING.
    METHODS minimum_combinations FOR TESTING.
    METHODS smaller_minimum FOR TESTING.
    METHODS changed_target FOR TESTING.
ENDCLASS.

CLASS ltc_containers IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD example.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `20` ) ( `15` ) ( `10` ) ( `5` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
  ENDMETHOD.

  METHOD duplicate_containers.
    mo_cut->mv_liters = 10.
    mo_cut->init( VALUE #( ( `5` ) ( `5` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `3` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
  ENDMETHOD.

  METHOD default_150_liters.
    mo_cut->init( VALUE #( ( `100` ) ( `50` ) ( `75` ) ( `75` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `2` ).
  ENDMETHOD.

  METHOD no_container_reuse.
    mo_cut->mv_liters = 10.
    mo_cut->init( VALUE #( ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.

  METHOD no_solution.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `20` ) ( `10` ) ( `30` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.

  METHOD reinitialize.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `20` ) ( `15` ) ( `10` ) ( `5` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
    mo_cut->init( VALUE #( ( `25` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `0` ).
  ENDMETHOD.

  METHOD blank_lines.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `` ) ( `  ` ) ( ` 25 ` ) ( `` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
  ENDMETHOD.
  METHOD minimum_combinations.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `20` ) ( `15` ) ( `10` ) ( `5` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `3` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
  ENDMETHOD.

  METHOD smaller_minimum.
    mo_cut->mv_liters = 25.
    mo_cut->init( VALUE #( ( `25` ) ( `25` ) ( `20` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `2` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `3` ).
  ENDMETHOD.

  METHOD changed_target.
    mo_cut->init( VALUE #( ( `100` ) ( `50` ) ( `75` ) ( `75` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `2` ).
    mo_cut->mv_liters = 100.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
  ENDMETHOD.
ENDCLASS.
