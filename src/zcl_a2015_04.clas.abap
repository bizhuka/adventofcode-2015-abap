CLASS zcl_a2015_04 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.

  PRIVATE SECTION.
    DATA:
      mv_input   TYPE string,
      mv_number5 TYPE ty_big_int,
      mv_number6 TYPE ty_big_int.
    METHODS:
      _get_number IMPORTING iv_number         TYPE i
                  RETURNING VALUE(rv_number) TYPE ty_big_int.
ENDCLASS.



CLASS zcl_a2015_04 IMPLEMENTATION.
  METHOD init.
    mv_input = it_input[ 1 ].
    CLEAR: mv_number5, mv_number6.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = _get_number( iv_number = 5 ).
  ENDMETHOD.

  METHOD get_result2.
    rv_result = _get_number( iv_number = 6 ).
  ENDMETHOD.

  METHOD _get_number.
    rv_number = SWITCH #( iv_number WHEN 5 THEN mv_number5
                                   WHEN 6 THEN mv_number6 ).
    CHECK rv_number IS INITIAL.

    " Six leading zeroes also satisfy Part 1, so earlier candidates cannot win.
    " Include the Part 1 candidate itself: it might already have six zeroes.
    rv_number = COND #( WHEN iv_number = 6 AND mv_number5 > 0
                          THEN mv_number5 - 1 ELSE 0 ).

    " Check 20 or 24 zero bits without converting each digest to hexadecimal text.
    CONSTANTS: lc_mask5 TYPE x LENGTH 3 VALUE 'FFFFF0',
               lc_mask6 TYPE x LENGTH 3 VALUE 'FFFFFF',
               lc_zero  TYPE x LENGTH 3 VALUE '000000'.
    DATA(lv_mask) = COND #( WHEN iv_number = 5 THEN lc_mask5 ELSE lc_mask6 ).
    DATA lv_hash TYPE x LENGTH 16.
    DATA lv_prefix TYPE x LENGTH 3.
    IF sy-saprl = 'OPEN'.
      " Keep the hot loop in Node, while sharing ABAP's candidate bounds and result cache.
      DATA(lv_input) = mv_input.
      WRITE '@KERNEL const { mineMd5 } = await import("../../runtime/day04.mjs");'.
      WRITE '@KERNEL rv_number.set(mineMd5(lv_input.get(), iv_number.get(), Number(rv_number.get())));'.
    ELSE.
      DO.
        rv_number += 1.
        TRY.
            cl_abap_message_digest=>calculate_hash_for_char(
              EXPORTING if_data      = |{ mv_input }{ rv_number }|
                        if_algorithm = 'MD5'
              IMPORTING ef_hashx     = lv_hash ).
          CATCH cx_abap_message_digest.
            rv_number = -1.
            RETURN.
        ENDTRY.
        lv_prefix = lv_hash(3) BIT-AND lv_mask.
        CHECK lv_prefix = lc_zero.
        EXIT.
      ENDDO.
    ENDIF.

    CASE iv_number.
      WHEN 5. mv_number5 = rv_number.
      WHEN 6. mv_number6 = rv_number.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
