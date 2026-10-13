CLASS zcl_a2015_13 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_happiness,
        guest TYPE string,
        neighbor TYPE string,
        amount TYPE ty_big_int,
      END OF ty_happiness,
      tt_happiness TYPE HASHED TABLE OF ty_happiness WITH UNIQUE KEY guest neighbor.
    DATA: mt_happiness TYPE tt_happiness,
          mt_guests TYPE string_table.
    METHODS:
      solve IMPORTING iv_include_self TYPE abap_bool DEFAULT abap_false
            RETURNING VALUE(rv_total) TYPE ty_big_int,
      best_order IMPORTING iv_first TYPE string
                           iv_last TYPE string
                           it_remaining TYPE string_table
                 RETURNING VALUE(rv_total) TYPE ty_big_int,
      pair_happiness IMPORTING iv_guest TYPE string
                               iv_neighbor TYPE string
                     RETURNING VALUE(rv_total) TYPE ty_big_int.
ENDCLASS.

CLASS zcl_a2015_13 IMPLEMENTATION.
  METHOD init.
    CLEAR: mt_happiness, mt_guests.
    LOOP AT it_input INTO DATA(lv_line).
      FIND REGEX '^([A-Za-z]+) would (gain|lose) ([0-9]+) happiness units by sitting next to ([A-Za-z]+)\.'
        IN lv_line SUBMATCHES DATA(lv_guest) DATA(lv_sign) DATA(lv_amount) DATA(lv_neighbor).
      CHECK sy-subrc = 0.
      DATA(lv_happiness) = CONV ty_big_int( lv_amount ).
      IF lv_sign = 'lose'.
        lv_happiness = - lv_happiness.
      ENDIF.
      INSERT VALUE #( guest = lv_guest neighbor = lv_neighbor amount = lv_happiness )
        INTO TABLE mt_happiness.
      IF NOT line_exists( mt_guests[ table_line = lv_guest ] ).
        APPEND lv_guest TO mt_guests.
      ENDIF.
      IF NOT line_exists( mt_guests[ table_line = lv_neighbor ] ).
        APPEND lv_neighbor TO mt_guests.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = |{ solve( ) }|.
  ENDMETHOD.

  METHOD get_result2.
    rv_result = |{ solve( iv_include_self = abap_true ) }|.
  ENDMETHOD.

  METHOD solve.
    DATA(lt_remaining) = mt_guests.
    " An empty name represents ourselves, with zero happiness in both directions.
    IF iv_include_self = abap_true.
      APPEND INITIAL LINE TO lt_remaining.
    ENDIF.
    CHECK lines( lt_remaining ) > 1.
    " Fix one seat: rotating a circular arrangement does not change its score.
    DATA(lv_first) = lt_remaining[ 1 ].
    DELETE lt_remaining INDEX 1.
    rv_total = best_order( iv_first = lv_first iv_last = lv_first it_remaining = lt_remaining ).
  ENDMETHOD.

  METHOD best_order.
    IF it_remaining IS INITIAL.
      rv_total = pair_happiness( iv_guest = iv_last iv_neighbor = iv_first ).
      RETURN.
    ENDIF.
    DATA(lv_has_best) = abap_false.
    LOOP AT it_remaining INTO DATA(lv_next).
      DATA(lv_index) = sy-tabix.
      DATA(lt_remaining) = it_remaining.
      DELETE lt_remaining INDEX lv_index.
      DATA(lv_total) = pair_happiness( iv_guest = iv_last iv_neighbor = lv_next )
        + best_order( iv_first = iv_first iv_last = lv_next it_remaining = lt_remaining ).
      IF lv_has_best = abap_false OR lv_total > rv_total.
        rv_total = lv_total.
        lv_has_best = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD pair_happiness.
    READ TABLE mt_happiness WITH TABLE KEY guest = iv_guest neighbor = iv_neighbor INTO DATA(ls_happiness).
    IF sy-subrc = 0.
      rv_total = ls_happiness-amount.
    ENDIF.
    READ TABLE mt_happiness WITH TABLE KEY guest = iv_neighbor neighbor = iv_guest INTO ls_happiness.
    IF sy-subrc = 0.
      rv_total = rv_total + ls_happiness-amount.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

