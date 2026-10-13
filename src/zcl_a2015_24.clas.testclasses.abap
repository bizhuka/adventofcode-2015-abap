CLASS ltc_balance DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_24.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS remainder_must_partition FOR TESTING.
    METHODS duplicate_packages FOR TESTING.
    METHODS single_package_group FOR TESTING.
    METHODS impossible_partition FOR TESTING.
    METHODS indivisible_total FOR TESTING.
    METHODS large_quantum_entanglement FOR TESTING.
    METHODS empty_input FOR TESTING.
    METHODS input_order FOR TESTING.
    METHODS repeat_and_line_endings FOR TESTING.
    METHODS puzzle_input FOR TESTING.
ENDCLASS.

CLASS ltc_balance IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD example.
    mo_cut->init( VALUE #( ( `1` ) ( `2` ) ( `3` ) ( `4` ) ( `5` ) ( `7` ) ( `8` ) ( `9` ) ( `10` ) ( `11` ) ) ).
    " The three-item QE 90 loses to the two-item QE 99: cardinality comes first.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `99` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `44` ).
  ENDMETHOD.

  METHOD remainder_must_partition.
    " QE 600 reaches the target but strands the other packages; QE 605 is valid.
    mo_cut->init( VALUE #( ( `1` ) ( `12` ) ( `11` ) ( `12` ) ( `10` ) ( `8` ) ( `2` ) ( `9` ) ( `11` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `605` ).
    " A second independent counterexample to accepting the smallest product alone.
    mo_cut->init( VALUE #( ( `12` ) ( `7` ) ( `4` ) ( `13` ) ( `10` ) ( `13` ) ( `14` ) ( `1` ) ( `3` ) ( `10` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `507` ).
  ENDMETHOD.

  METHOD duplicate_packages.
    mo_cut->init( VALUE #( ( `1` ) ( `1` ) ( `1` ) ( `1` ) ( `2` ) ( `2` ) ( `2` ) ( `2` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `2` ).
  ENDMETHOD.

  METHOD single_package_group.
    mo_cut->init( VALUE #( ( `5` ) ( `5` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `5` ).
    mo_cut->init( VALUE #( ( `7` ) ( `7` ) ( `7` ) ( `7` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `7` ).
  ENDMETHOD.

  METHOD impossible_partition.
    " Total 12 is divisible by three, but the remaining 2,3,3 cannot form groups of 4.
    mo_cut->init( VALUE #( ( `2` ) ( `2` ) ( `2` ) ( `3` ) ( `3` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `-1` ).
    mo_cut->init( VALUE #( ( `1` ) ( `2` ) ( `3` ) ( `4` ) ( `8` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
  ENDMETHOD.

  METHOD indivisible_total.
    mo_cut->init( VALUE #( ( `1` ) ( `2` ) ( `4` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `-1` ).
  ENDMETHOD.

  METHOD large_quantum_entanglement.
    DATA(lt_input) = VALUE string_table( FOR lv_index = 1 UNTIL lv_index > 9 ( `10000` ) ).
    mo_cut->init( lt_input ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1000000000000` ).
  ENDMETHOD.

  METHOD empty_input.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `-1` ).
  ENDMETHOD.

  METHOD input_order.
    mo_cut->init( VALUE #( ( `11` ) ( `1` ) ( `10` ) ( `2` ) ( `9` ) ( `3` ) ( `8` ) ( `4` ) ( `7` ) ( `5` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `44` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `99` ).
  ENDMETHOD.

  METHOD repeat_and_line_endings.
    mo_cut->init( VALUE #( ( |1{ cl_abap_char_utilities=>newline }1{ cl_abap_char_utilities=>newline }1| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    mo_cut->init( VALUE #( ( `` ) ( | 7 { cl_abap_char_utilities=>cr_lf }7{ cl_abap_char_utilities=>cr_lf }7{ cl_abap_char_utilities=>cr_lf }7| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `7` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `-1` ).
  ENDMETHOD.

  METHOD puzzle_input.
    mo_cut->init( VALUE #( ( `1` ) ( `3` ) ( `5` ) ( `11` ) ( `13` ) ( `17` ) ( `19` ) ( `23` )
      ( `29` ) ( `31` ) ( `41` ) ( `43` ) ( `47` ) ( `53` ) ( `59` ) ( `61` ) ( `67` ) ( `71` )
      ( `73` ) ( `79` ) ( `83` ) ( `89` ) ( `97` ) ( `101` ) ( `103` ) ( `107` ) ( `109` ) ( `113` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `11266889531` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `77387711` ).
  ENDMETHOD.
ENDCLASS.
