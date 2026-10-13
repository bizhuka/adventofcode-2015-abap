CLASS zcl_a2015_23 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_instruction,
             opcode TYPE c LENGTH 3,
             register TYPE i,
             offset TYPE i,
           END OF ty_instruction,
           BEGIN OF ty_registers,
             a TYPE ty_big_int,
             b TYPE ty_big_int,
           END OF ty_registers.
    TYPES tt_program TYPE STANDARD TABLE OF ty_instruction WITH EMPTY KEY.
    DATA mt_program TYPE tt_program.
    METHODS execute
      IMPORTING iv_a TYPE ty_big_int DEFAULT 0
      RETURNING VALUE(rs_registers) TYPE ty_registers.
ENDCLASS.

CLASS zcl_a2015_23 IMPLEMENTATION.
  METHOD init.
    CLEAR mt_program.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = <lv_line>.
      REPLACE ALL OCCURRENCES OF ',' IN lv_line WITH ' '.
      lv_line = condense( lv_line ).
      CHECK lv_line IS NOT INITIAL.
      SPLIT lv_line AT ' ' INTO DATA(lv_opcode) DATA(lv_operand) DATA(lv_offset).
      ASSERT lv_opcode = 'hlf' OR lv_opcode = 'tpl' OR lv_opcode = 'inc'
        OR lv_opcode = 'jmp' OR lv_opcode = 'jie' OR lv_opcode = 'jio'.
      DATA(ls_instruction) = VALUE ty_instruction(
        opcode = lv_opcode register = COND #( WHEN lv_operand = 'b' THEN 2 ELSE 1 )
        offset = COND #( WHEN lv_opcode = 'jmp' THEN CONV i( lv_operand )
                         WHEN lv_opcode = 'jie' OR lv_opcode = 'jio' THEN CONV i( lv_offset ) ELSE 0 ) ).
      ASSERT lv_opcode = 'jmp' OR lv_operand = 'a' OR lv_operand = 'b'.
      APPEND ls_instruction TO mt_program.
    ENDLOOP.
  ENDMETHOD.

  METHOD execute.
    " Parse once in init; execution uses indexed instructions and 64-bit registers.
    DATA(lt_registers) = VALUE tt_big_int( ( iv_a ) ( CONV #( 0 ) ) ).
    DATA(lv_pc) = 1.
    DATA(lv_length) = lines( mt_program ).
    WHILE lv_pc >= 1 AND lv_pc <= lv_length.
      ASSIGN mt_program[ lv_pc ] TO FIELD-SYMBOL(<ls_instruction>).
      ASSIGN lt_registers[ <ls_instruction>-register ] TO FIELD-SYMBOL(<lv_register>).
      DATA(lv_step) = 1.
      CASE <ls_instruction>-opcode.
        WHEN 'hlf'. <lv_register> = CONV ty_big_int( <lv_register> ) DIV 2.
        WHEN 'tpl'. <lv_register> = CONV ty_big_int( <lv_register> ) * 3.
        WHEN 'inc'. <lv_register> = CONV ty_big_int( <lv_register> ) + 1.
        WHEN 'jmp'. lv_step = <ls_instruction>-offset.
        WHEN 'jie'.
          lv_step = COND #( WHEN CONV ty_big_int( <lv_register> ) MOD 2 = 0
                            THEN <ls_instruction>-offset ELSE 1 ).
        WHEN 'jio'.
          lv_step = COND #( WHEN CONV ty_big_int( <lv_register> ) = 1
                            THEN <ls_instruction>-offset ELSE 1 ).
      ENDCASE.
      " Jumps are relative to the current instruction, including negative offsets.
      lv_pc = lv_pc + lv_step.
    ENDWHILE.
    rs_registers = VALUE #( a = lt_registers[ 1 ] b = lt_registers[ 2 ] ).
  ENDMETHOD.

  METHOD get_result1.
    DATA(ls_registers) = execute( ).
    rv_result = |{ ls_registers-b }|.
  ENDMETHOD.

  METHOD get_result2.
    DATA(ls_registers) = execute( iv_a = 1 ).
    rv_result = |{ ls_registers-b }|.
  ENDMETHOD.
ENDCLASS.
