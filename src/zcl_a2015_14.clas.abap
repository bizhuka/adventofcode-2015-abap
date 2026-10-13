CLASS zcl_a2015_14 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_seconds TYPE i VALUE 2503.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_reindeer,
             speed TYPE i,
             flying TYPE i,
             resting TYPE i,
             points TYPE i,
           END OF ty_reindeer.
    DATA mt_reindeer TYPE STANDARD TABLE OF ty_reindeer WITH EMPTY KEY.
    METHODS distance IMPORTING is_reindeer TYPE ty_reindeer
                               iv_seconds TYPE i
                     RETURNING VALUE(rv_distance) TYPE ty_big_int.
ENDCLASS.

CLASS zcl_a2015_14 IMPLEMENTATION.
  METHOD init.
    CLEAR mt_reindeer.
    LOOP AT it_input INTO DATA(lv_line).
      FIND REGEX '^([A-Za-z]+) can fly ([0-9]+) km/s for ([0-9]+) seconds, but then must rest for ([0-9]+) seconds\.'
        IN lv_line SUBMATCHES DATA(lv_name) DATA(lv_speed) DATA(lv_flying) DATA(lv_resting).
      CHECK sy-subrc = 0.
      APPEND VALUE #( speed = CONV i( lv_speed ) flying = CONV i( lv_flying )
                      resting = CONV i( lv_resting ) ) TO mt_reindeer.
    ENDLOOP.
  ENDMETHOD.

  METHOD distance.
    DATA(lv_cycle) = is_reindeer-flying + is_reindeer-resting.
    CHECK lv_cycle > 0 AND iv_seconds > 0.
    rv_distance = CONV ty_big_int( is_reindeer-speed ) *
      ( ( iv_seconds DIV lv_cycle ) * is_reindeer-flying +
        nmin( val1 = iv_seconds MOD lv_cycle val2 = is_reindeer-flying ) ).
  ENDMETHOD.

  METHOD get_result1.
    DATA lv_best TYPE ty_big_int.
    LOOP AT mt_reindeer INTO DATA(ls_reindeer).
      lv_best = nmax( val1 = lv_best val2 = distance( is_reindeer = ls_reindeer iv_seconds = mv_seconds ) ).
    ENDLOOP.
    rv_result = |{ lv_best }|.
  ENDMETHOD.

  METHOD get_result2.
    LOOP AT mt_reindeer ASSIGNING FIELD-SYMBOL(<ls_reindeer>).
      CLEAR <ls_reindeer>-points.
    ENDLOOP.
    DO mv_seconds TIMES.
      DATA(lv_second) = sy-index.
      DATA(lv_lead) = CONV ty_big_int( 0 ).
      LOOP AT mt_reindeer INTO DATA(ls_reindeer).
        lv_lead = nmax( val1 = lv_lead val2 = distance( is_reindeer = ls_reindeer iv_seconds = lv_second ) ).
      ENDLOOP.
      LOOP AT mt_reindeer ASSIGNING <ls_reindeer>.
        IF distance( is_reindeer = <ls_reindeer> iv_seconds = lv_second ) = lv_lead.
          <ls_reindeer>-points = <ls_reindeer>-points + 1.
        ENDIF.
      ENDLOOP.
    ENDDO.
    DATA lv_best TYPE i.
    LOOP AT mt_reindeer INTO ls_reindeer.
      lv_best = nmax( val1 = lv_best val2 = ls_reindeer-points ).
    ENDLOOP.
    rv_result = |{ lv_best }|.
  ENDMETHOD.
ENDCLASS.
