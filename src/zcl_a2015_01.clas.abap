CLASS zcl_a2015_01 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.
    DATA:
      mv_input TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_a2015_01 IMPLEMENTATION.
  METHOD init.
    mv_input = it_input[ 1 ].
  ENDMETHOD.


  METHOD get_result1.
*                REDUCE #( INIT s = CONV ty_big_int( 0 )
*                          FOR i = 0 UNTIL i >= strlen( mv_input )
*                          NEXT s += SWITCH #( mv_input+i(1)
*                               WHEN `(` THEN 1
*                               WHEN `)` THEN -1 ) ).
    rv_result = |{ count( val = mv_input sub = `(` ) - count( val = mv_input sub = `)` ) }|.
  ENDMETHOD.


  METHOD get_result2.
*    rv_result = REDUCE #(
*          INIT s = CONV ty_big_int( 0 )
*          FOR i = 0 UNTIL s = -1 OR i >= strlen( mv_input )
*          NEXT s += COND i( WHEN mv_input+i(1) = `(` THEN 1 ELSE -1 )  ).

    DATA(lv_sum) = CONV ty_big_int( 0 ).
    DO strlen( mv_input ) TIMES.
      rv_result = sy-index.

      DATA(lv_offset) = sy-index - 1.
      lv_sum += SWITCH #( mv_input+lv_offset(1) WHEN `(` THEN 1
                                                WHEN `)` THEN -1 ).
      CHECK lv_sum = -1.
      RETURN.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
