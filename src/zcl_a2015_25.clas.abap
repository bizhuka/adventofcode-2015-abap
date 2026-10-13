CLASS zcl_a2015_25 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    CONSTANTS c_first TYPE ty_big_int VALUE 20151125.
    CONSTANTS c_multiplier TYPE ty_big_int VALUE 252533.
    CONSTANTS c_modulus TYPE ty_big_int VALUE 33554393.
    DATA mv_row TYPE ty_big_int.
    DATA mv_column TYPE ty_big_int.
    METHODS code_at
      IMPORTING iv_row TYPE ty_big_int iv_column TYPE ty_big_int
      RETURNING VALUE(rv_code) TYPE ty_big_int.
ENDCLASS.

CLASS zcl_a2015_25 IMPLEMENTATION.
  METHOD init.
    CLEAR: mv_row, mv_column.
    DATA(lv_content) = concat_lines_of( table = it_input sep = ` ` ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH ` `.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_content WITH ` `.
    lv_content = condense( lv_content ).
    FIND REGEX 'row ([0-9]+), column ([0-9]+)' IN lv_content
      SUBMATCHES DATA(lv_row) DATA(lv_column).
    ASSERT sy-subrc = 0.
    mv_row = CONV ty_big_int( lv_row ).
    mv_column = CONV ty_big_int( lv_column ).
    ASSERT mv_row > 0 AND mv_column > 0.
  ENDMETHOD.

  METHOD code_at.
    ASSERT iv_row > 0 AND iv_column > 0.
    " Diagonal d starts after 1+2+...+(d-1) cells; column counts along it.
    DATA(lv_diagonal) = iv_row + iv_column - 1.
    DATA(lv_exponent) = lv_diagonal * ( lv_diagonal - 1 ) DIV 2 + iv_column - 1.
    DATA(lv_power) = c_multiplier.
    rv_code = c_first.
    " Binary modular exponentiation needs O(log(index)) work and constant space.
    " int8 keeps modular products exact; they remain below modulus squared.
    WHILE lv_exponent > 0.
      rv_code = COND #( WHEN lv_exponent MOD 2 = 1 THEN ( rv_code * lv_power ) MOD c_modulus ELSE rv_code ).
      lv_power = ( lv_power * lv_power ) MOD c_modulus.
      lv_exponent = lv_exponent DIV 2.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = |{ code_at( iv_row = mv_row iv_column = mv_column ) }|.
  ENDMETHOD.

  METHOD get_result2.
    " Day 25 has no second code calculation.
    rv_result = `Merry Christmas!`.
  ENDMETHOD.
ENDCLASS.
