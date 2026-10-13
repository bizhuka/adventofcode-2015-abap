CLASS zcl_a2015_02 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.
    DATA:
      mt_input  TYPE string_table.
ENDCLASS.


CLASS zcl_a2015_02 IMPLEMENTATION.
  METHOD init.
    mt_input[] = it_input[].
  ENDMETHOD.

  METHOD get_result1.
    LOOP AT mt_input INTO DATA(lv_input).
      SPLIT lv_input AT `x` INTO DATA(lv_length_str)
                                 DATA(lv_width_str)
                                 DATA(lv_height_str).
      DATA(lv_length) = CONV ty_big_int( lv_length_str ).
      DATA(lv_width)  = CONV ty_big_int( lv_width_str ).
      DATA(lv_height) = CONV ty_big_int( lv_height_str ).

      DATA(lv_area) = 2 * lv_length * lv_width  +
                      2 * lv_width  * lv_height +
                      2 * lv_height * lv_length.

      rv_result += ( lv_area + nmin( val1 = lv_length * lv_width
                                     val2 = lv_width  * lv_height
                                     val3 = lv_height * lv_length ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result2.
    LOOP AT mt_input INTO DATA(lv_input).
      SPLIT lv_input AT `x` INTO DATA(lv_length_str)
                                 DATA(lv_width_str)
                                 DATA(lv_height_str).
      DATA(lv_length) = CONV ty_big_int( lv_length_str ).
      DATA(lv_width)  = CONV ty_big_int( lv_width_str ).
      DATA(lv_height) = CONV ty_big_int( lv_height_str ).

      DATA(lv_wrap) = nmin( val1 = 2 * lv_length + 2 * lv_width
                            val2 = 2 * lv_width  + 2 * lv_height
                            val3 = 2 * lv_height + 2 * lv_length ).

      rv_result += ( lv_wrap + lv_length * lv_width * lv_height ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
