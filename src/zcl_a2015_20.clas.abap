CLASS zcl_a2015_20 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    DATA mv_target TYPE ty_big_int.
    DATA mv_result1 TYPE i.
    DATA mv_result2 TYPE i.
    METHODS lowest_house
      IMPORTING iv_multiplier TYPE i
                iv_max_visits TYPE i DEFAULT 0
      RETURNING VALUE(rv_house) TYPE i.
ENDCLASS.

CLASS zcl_a2015_20 IMPLEMENTATION.
  METHOD init.
    CLEAR: mv_target, mv_result1, mv_result2.
    " W3MI text can use LF even though the shared runner splits on CRLF.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = condense( <lv_line> ).
      CHECK lv_line IS NOT INITIAL.
      mv_target = CONV ty_big_int( lv_line ).
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD lowest_house.
    IF mv_target <= 0.
      rv_house = 1.
      RETURN.
    ENDIF.

    " A house receives at least its own elf's gift, even with the 50-visit limit.
    " This upper bound guarantees a solution without guessing a search range.
    DATA(lv_limit) = CONV i( ( mv_target + iv_multiplier - 1 ) DIV iv_multiplier ).

    DATA(lt_presents) = VALUE tt_big_int( FOR lv_index = 1 UNTIL lv_index > lv_limit ( CONV #( 0 ) ) ).
    DO lv_limit TIMES.
      DATA(lv_elf) = sy-index.
      DATA(lv_deliveries) = COND i(
        WHEN iv_max_visits > 0 THEN nmin( val1 = lv_limit DIV lv_elf val2 = iv_max_visits )
        ELSE lv_limit DIV lv_elf ).
      DO lv_deliveries TIMES.
        DATA(lv_house) = lv_elf * sy-index.
        ASSIGN lt_presents[ lv_house ] TO FIELD-SYMBOL(<lv_presents>).
        " The local int8 operators need concrete values rather than field-symbol wrappers.
        <lv_presents> = CONV ty_big_int( <lv_presents> ) + CONV ty_big_int( lv_elf ) * iv_multiplier.
      ENDDO.
    ENDDO.

    LOOP AT lt_presents ASSIGNING <lv_presents>.
      CHECK CONV ty_big_int( <lv_presents> ) >= mv_target.
      rv_house = sy-tabix.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result1.
    IF mv_result1 = 0.
      mv_result1 = lowest_house( iv_multiplier = 10 ).
    ENDIF.
    rv_result = |{ mv_result1 }|.
  ENDMETHOD.

  METHOD get_result2.
    IF mv_result2 = 0.
      mv_result2 = lowest_house( iv_multiplier = 11 iv_max_visits = 50 ).
    ENDIF.
    rv_result = |{ mv_result2 }|.
  ENDMETHOD.
ENDCLASS.
