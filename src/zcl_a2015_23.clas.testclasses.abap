CLASS ltc_computer DEFINITION DEFERRED.
CLASS zcl_a2015_23 DEFINITION LOCAL FRIENDS ltc_computer.

CLASS ltc_computer DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_23.
    METHODS setup.
    METHODS example FOR TESTING.
    METHODS arithmetic FOR TESTING.
    METHODS jump_if_even FOR TESTING.
    METHODS jump_if_one_not_odd FOR TESTING.
    METHODS backward_jump FOR TESTING.
    METHODS exit_in_both_directions FOR TESTING.
    METHODS untaken_zero_offset FOR TESTING.
    METHODS large_registers FOR TESTING.
    METHODS empty_and_line_endings FOR TESTING.
    METHODS repeat_and_reinitialize FOR TESTING.
    METHODS puzzle_input FOR TESTING.
ENDCLASS.

CLASS ltc_computer IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD example.
    mo_cut->init( VALUE #( ( `inc a` ) ( `jio a, +2` ) ( `tpl a` ) ( `inc a` ) ) ).
    DATA(ls_registers) = mo_cut->execute( ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-a exp = CONV int8( 2 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-b exp = CONV int8( 0 ) ).
  ENDMETHOD.

  METHOD arithmetic.
    mo_cut->init( VALUE #( ( `inc b` ) ( `tpl b` ) ( `tpl b` ) ( `hlf b` ) ( `inc b` ) ( `hlf b` ) ) ).
    DATA(ls_registers) = mo_cut->execute( ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-a exp = CONV int8( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-b exp = CONV int8( 2 ) ).
  ENDMETHOD.

  METHOD jump_if_even.
    " Zero is even, and the jump is relative to the current instruction.
    mo_cut->init( VALUE #( ( `jie b, +2` ) ( `inc a` ) ( `inc b` ) ) ).
    DATA(ls_registers) = mo_cut->execute( ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-a exp = CONV int8( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-b exp = CONV int8( 1 ) ).
    mo_cut->init( VALUE #( ( `inc b` ) ( `inc b` ) ( `jie b, +2` ) ( `tpl b` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `3` ).
  ENDMETHOD.

  METHOD jump_if_one_not_odd.
    mo_cut->init( VALUE #( ( `inc b` ) ( `jio b, +2` ) ( `tpl b` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    mo_cut->init( VALUE #( ( `inc b` ) ( `tpl b` ) ( `jio b, +2` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
  ENDMETHOD.

  METHOD backward_jump.
    mo_cut->init( VALUE #( ( `jio a, +5` ) ( `inc b` ) ( `hlf a` ) ( `jmp -3` ) ( `inc b` ) ) ).
    DATA(ls_registers) = mo_cut->execute( iv_a = 8 ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-a exp = CONV int8( 1 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_registers-b exp = CONV int8( 3 ) ).
  ENDMETHOD.

  METHOD exit_in_both_directions.
    mo_cut->init( VALUE #( ( `jmp -1` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    mo_cut->init( VALUE #( ( `jmp +3` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    mo_cut->init( VALUE #( ( `inc b` ) ( `jmp +2` ) ( `tpl b` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
  ENDMETHOD.

  METHOD untaken_zero_offset.
    mo_cut->init( VALUE #( ( `inc b` ) ( `jie b, +0` ) ( `inc b` ) ( `jio b, +0` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `3` ).
  ENDMETHOD.

  METHOD large_registers.
    DATA(lt_program) = VALUE string_table( ( `inc b` ) ).
    DO 22 TIMES.
      APPEND `tpl b` TO lt_program.
    ENDDO.
    APPEND `hlf b` TO lt_program.
    mo_cut->init( lt_program ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `15690529804` ).
  ENDMETHOD.

  METHOD empty_and_line_endings.
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `0` ).
    mo_cut->init( VALUE #( ( | inc b { cl_abap_char_utilities=>newline }{ cl_abap_char_utilities=>newline }tpl b| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `3` ).
    mo_cut->init( VALUE #( ( |inc b{ cl_abap_char_utilities=>cr_lf }jmp +2{ cl_abap_char_utilities=>cr_lf }inc b| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
  ENDMETHOD.

  METHOD repeat_and_reinitialize.
    mo_cut->init( VALUE #( ( `jio a, +2` ) ( `inc b` ) ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    mo_cut->init( VALUE #( ( `inc b` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
  ENDMETHOD.

  METHOD puzzle_input.
    mo_cut->init( VALUE #(
      ( `jio a, +18` ) ( `inc a` ) ( `tpl a` ) ( `inc a` ) ( `tpl a` ) ( `tpl a` )
      ( `tpl a` ) ( `inc a` ) ( `tpl a` ) ( `inc a` ) ( `tpl a` ) ( `inc a` )
      ( `inc a` ) ( `tpl a` ) ( `tpl a` ) ( `tpl a` ) ( `inc a` ) ( `jmp +22` )
      ( `tpl a` ) ( `inc a` ) ( `tpl a` ) ( `inc a` ) ( `inc a` ) ( `tpl a` )
      ( `inc a` ) ( `tpl a` ) ( `inc a` ) ( `inc a` ) ( `tpl a` ) ( `tpl a` )
      ( `inc a` ) ( `inc a` ) ( `tpl a` ) ( `inc a` ) ( `inc a` ) ( `tpl a` )
      ( `inc a` ) ( `inc a` ) ( `tpl a` ) ( `jio a, +8` ) ( `inc b` ) ( `jie a, +4` )
      ( `tpl a` ) ( `inc a` ) ( `jmp +2` ) ( `hlf a` ) ( `jmp -7` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `307` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `160` ).
  ENDMETHOD.
ENDCLASS.
