CLASS zcl_a2015_08 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION,

      calculate_diff IMPORTING iv_input       TYPE string
                     RETURNING VALUE(rv_diff) TYPE i,

      calculate_encoded_diff IMPORTING iv_input       TYPE string
                             RETURNING VALUE(rv_diff) TYPE i.
  PRIVATE SECTION.
    DATA:
      mt_input TYPE string_table.
ENDCLASS.

CLASS zcl_a2015_08 IMPLEMENTATION.

  METHOD init.
    mt_input[] = it_input[].
  ENDMETHOD.

  METHOD calculate_diff.
*    DATA(lv_total)  = strlen( iv_input ).
*    DATA(lv_actual) = lv_total - 2.
*
*    DATA(lv_index) = 0.
*    WHILE lv_index < lv_total - 2.
*      lv_index += 1.
*
*      CHECK iv_input+lv_index(1) = '\'.
*      lv_actual -= 1.
*      lv_index  += 1.
*
*      CHECK iv_input+lv_index(1) = 'x'.
*      lv_actual -= 2.
*      lv_index  += 2.
*    ENDWHILE.
*
*    rv_diff = lv_total - lv_actual.

    " Logic: Code Length - Memory Length
    " Memory Length: Use regex to replace valid escape sequences (\\, \", \x..)
    " with a single placeholder character, then measure the length.
    " Note: We strip the outer quotes first (off=1, len-2).
    DATA(lv_memory) = replace( val   = substring( val = iv_input off = 1 len = strlen( iv_input ) - 2 )
                               regex = `\\\\` && " \\
                                       `|`    && " OR
                                       `\\"`  && " \"
                                       `|`    && " OR
                                       `\\x..`   " \x..
                               with  = `.`
                               occ   = 0 ).

    rv_diff = strlen( iv_input ) - strlen( lv_memory ).

  ENDMETHOD.

  METHOD calculate_encoded_diff.
    " Logic: The new length increases by 2 (for surrounding quotes)
    " plus 1 for every existing backslash (it gets escaped)
    " plus 1 for every existing quote (it gets escaped)
    rv_diff = 2 + count( val = iv_input sub = `\` ) +
                  count( val = iv_input sub = `"` ).
  ENDMETHOD.

  METHOD get_result1.
    rv_result = REDUCE #(
      INIT s = 0
      FOR line IN mt_input
      NEXT s += calculate_diff( line )
    ).
  ENDMETHOD.

  METHOD get_result2.
    rv_result = REDUCE #(
      INIT s = 0
      FOR line IN mt_input
      NEXT s += calculate_encoded_diff( line )
    ).
  ENDMETHOD.

ENDCLASS.
