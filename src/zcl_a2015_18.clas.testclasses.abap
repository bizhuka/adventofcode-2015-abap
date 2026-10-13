CLASS ltcl_lights DEFINITION DEFERRED.
CLASS zcl_a2015_18 DEFINITION LOCAL FRIENDS ltcl_lights.

CLASS ltcl_lights DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS example FOR TESTING.
    METHODS simultaneous_updates FOR TESTING.
    METHODS edges_are_off FOR TESTING.
    METHODS repeated_calls_and_reset FOR TESTING.
    METHODS stuck_corners_example FOR TESTING.
    METHODS stuck_corners_and_reset FOR TESTING.
    METHODS ragged_rows FOR TESTING.
    METHODS single_column FOR TESTING.
    METHODS zero_steps FOR TESTING.
    METHODS full_sized_stable_blocks FOR TESTING.
ENDCLASS.

CLASS ltcl_lights IMPLEMENTATION.
  METHOD example.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `.#.#.#` ) ( `...##.` ) ( `#....#` )
                          ( `..#...` ) ( `#.#..#` ) ( `####..` ) ) ).
    " The four-light block reached after step 4 stays unchanged.
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
  ENDMETHOD.

  METHOD simultaneous_updates.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `.....` ) ( `.....` ) ( `.###.` )
                          ( `.....` ) ( `.....` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `3` ).
  ENDMETHOD.

  METHOD edges_are_off.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `#...#` ) ( `.....` ) ( `.....` )
                          ( `.....` ) ( `#...#` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `0` ).
    lo_cut->init( VALUE #( ( `##` ) ( `##` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
  ENDMETHOD.

  METHOD repeated_calls_and_reset.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `##` ) ( `##` ) ( `` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
    lo_cut->get_result2( ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
    lo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `0` ).
    lo_cut->init( VALUE #( ( `#` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `0` ).
  ENDMETHOD.

  METHOD stuck_corners_example.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `.#.#.#` ) ( `...##.` ) ( `#....#` )
                          ( `..#...` ) ( `#.#..#` ) ( `####..` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->simulate( iv_stuck_corners = abap_true iv_steps = 0 ) exp = `17` ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->simulate( iv_stuck_corners = abap_true iv_steps = 1 ) exp = `18` ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->simulate( iv_stuck_corners = abap_true iv_steps = 5 ) exp = `17` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `4` ).
  ENDMETHOD.

  METHOD stuck_corners_and_reset.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `....` ) ( `....` ) ( `....` ) ( `....` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result2( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result2( ) exp = `4` ).
    lo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result2( ) exp = `0` ).
    lo_cut->init( VALUE #( ( `.` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result2( ) exp = `1` ).
  ENDMETHOD.

  METHOD ragged_rows.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `###` ) ( `#` ) ( `##` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->simulate( iv_steps = 1 ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->simulate( iv_steps = 2 ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->simulate( iv_stuck_corners = abap_true iv_steps = 2 ) exp = `5` ).
  ENDMETHOD.

  METHOD single_column.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `#` ) ( `#` ) ( `#` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->simulate( iv_steps = 1 ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->simulate( iv_steps = 2 ) exp = `0` ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result2( ) exp = `3` ).
  ENDMETHOD.

  METHOD zero_steps.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    lo_cut->init( VALUE #( ( `#.` ) ( `.###` ) ( `..` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->simulate( iv_steps = 0 ) exp = `4` ).
  ENDMETHOD.

  METHOD full_sized_stable_blocks.
    DATA(lo_cut) = NEW zcl_a2015_18( ).
    DATA(lv_block_row) = repeat( val = `##..` occ = 25 ).
    DATA(lv_empty_row) = repeat( val = `.` occ = 100 ).
    lo_cut->init( VALUE #( FOR lv_row_index = 1 UNTIL lv_row_index > 100
                          ( COND string( WHEN ( lv_row_index - 1 ) MOD 4 < 2
                                         THEN lv_block_row ELSE lv_empty_row ) ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_cut->get_result1( ) exp = `2500` ).
  ENDMETHOD.
ENDCLASS.
