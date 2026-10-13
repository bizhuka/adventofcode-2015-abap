CLASS zcl_a2015_24 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES tt_weights TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES tt_used TYPE STANDARD TABLE OF abap_bool WITH EMPTY KEY.
    DATA mt_weights TYPE tt_weights.
    DATA mt_prefix TYPE tt_weights.
    DATA mt_used TYPE tt_used.
    DATA mv_count TYPE i.
    DATA mv_total TYPE i.
    DATA mv_target TYPE i.
    DATA mv_groups TYPE i.
    DATA mv_best TYPE ty_big_int.
    DATA mv_result1 TYPE string.
    DATA mv_result2 TYPE string.
    METHODS solve IMPORTING iv_groups TYPE i RETURNING VALUE(rv_qe) TYPE ty_big_int.
    METHODS first_group
      IMPORTING iv_start TYPE i iv_slots TYPE i iv_remaining TYPE i iv_qe TYPE ty_big_int.
    METHODS can_partition
      IMPORTING iv_groups TYPE i RETURNING VALUE(rv_possible) TYPE abap_bool.
    METHODS fill_group
      IMPORTING iv_start TYPE i iv_remaining TYPE i iv_groups TYPE i
      RETURNING VALUE(rv_possible) TYPE abap_bool.
ENDCLASS.

CLASS zcl_a2015_24 IMPLEMENTATION.
  METHOD init.
    CLEAR: mt_weights, mt_prefix, mt_used, mv_total, mv_count, mv_result1, mv_result2.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = condense( <lv_line> ).
      CHECK lv_line IS NOT INITIAL.
      DATA(lv_weight) = CONV i( lv_line ).
      ASSERT lv_weight > 0.
      APPEND lv_weight TO mt_weights.
    ENDLOOP.
    SORT mt_weights DESCENDING.
    mv_count = lines( mt_weights ).
    APPEND 0 TO mt_prefix.
    LOOP AT mt_weights ASSIGNING FIELD-SYMBOL(<lv_weight>).
      mv_total = mv_total + <lv_weight>.
      APPEND mv_total TO mt_prefix.
    ENDLOOP.
  ENDMETHOD.

  METHOD solve.
    rv_qe = -1.
    CHECK mv_count >= iv_groups AND mv_total MOD iv_groups = 0.
    mv_groups = iv_groups.
    mv_target = mv_total DIV iv_groups.
    CHECK mt_weights[ 1 ] <= mv_target.
    mt_used = VALUE #( FOR lv_index = 1 UNTIL lv_index > mv_count ( abap_false ) ).
    mv_best = -1.
    " Cardinality takes priority: never search larger groups after a valid size.
    DO mv_count TIMES.
      DATA(lv_slots) = sy-index.
      first_group( iv_start = 1 iv_slots = lv_slots iv_remaining = mv_target iv_qe = 1 ).
      CHECK mv_best >= 0.
      rv_qe = mv_best.
      RETURN.
    ENDDO.
  ENDMETHOD.

  METHOD first_group.
    CHECK mv_best < 0 OR iv_qe < mv_best.
    IF iv_slots = 0.
      CHECK iv_remaining = 0.
      CHECK can_partition( mv_groups - 1 ) = abap_true.
      mv_best = iv_qe.
      RETURN.
    ENDIF.
    CHECK iv_start + iv_slots - 1 <= mv_count.
    " Descending weights and prefix sums bound the largest and smallest
    " possible totals for the remaining slots without enumerating them.
    CHECK iv_remaining <= mt_prefix[ iv_start + iv_slots ] - mt_prefix[ iv_start ].
    CHECK iv_remaining >= mt_prefix[ mv_count + 1 ] - mt_prefix[ mv_count - iv_slots + 1 ].
    DATA(lv_last) = mv_count - iv_slots + 1.
    DATA(lv_previous) = -1.
    DO lv_last - iv_start + 1 TIMES.
      DATA(lv_index) = iv_start + sy-index - 1.
      DATA(lv_weight) = mt_weights[ lv_index ].
      CHECK lv_weight <> lv_previous.
      lv_previous = lv_weight.
      CHECK lv_weight <= iv_remaining.
      CHECK iv_slots > 1 OR lv_weight = iv_remaining.
      ASSIGN mt_used[ lv_index ] TO FIELD-SYMBOL(<lv_used>).
      <lv_used> = abap_true.
      first_group( iv_start = lv_index + 1 iv_slots = iv_slots - 1
        iv_remaining = iv_remaining - lv_weight iv_qe = iv_qe * CONV ty_big_int( lv_weight ) ).
      <lv_used> = abap_false.
    ENDDO.
  ENDMETHOD.

  METHOD can_partition.
    IF iv_groups = 1.
      " All completed groups have target weight, so the last group does too.
      rv_possible = abap_true.
      RETURN.
    ENDIF.
    " Groups are interchangeable. Force the largest unused package into the
    " next group to avoid checking permutations of the same partition.
    LOOP AT mt_weights ASSIGNING FIELD-SYMBOL(<lv_weight>).
      DATA(lv_index) = sy-tabix.
      CHECK mt_used[ lv_index ] = abap_false.
      ASSIGN mt_used[ lv_index ] TO FIELD-SYMBOL(<lv_used>).
      <lv_used> = abap_true.
      rv_possible = fill_group( iv_start = lv_index + 1 iv_remaining = mv_target - <lv_weight> iv_groups = iv_groups ).
      <lv_used> = abap_false.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD fill_group.
    IF iv_remaining = 0.
      rv_possible = can_partition( iv_groups - 1 ).
      RETURN.
    ENDIF.
    CHECK iv_remaining > 0 AND iv_start <= mv_count.
    CHECK iv_remaining <= mt_prefix[ mv_count + 1 ] - mt_prefix[ iv_start ].
    DATA(lv_previous) = -1.
    DO mv_count - iv_start + 1 TIMES.
      DATA(lv_index) = iv_start + sy-index - 1.
      CHECK mt_used[ lv_index ] = abap_false.
      DATA(lv_weight) = mt_weights[ lv_index ].
      CHECK lv_weight <> lv_previous.
      lv_previous = lv_weight.
      CHECK lv_weight <= iv_remaining.
      ASSIGN mt_used[ lv_index ] TO FIELD-SYMBOL(<lv_used>).
      <lv_used> = abap_true.
      rv_possible = fill_group( iv_start = lv_index + 1 iv_remaining = iv_remaining - lv_weight iv_groups = iv_groups ).
      <lv_used> = abap_false.
      CHECK rv_possible = abap_true.
      RETURN.
    ENDDO.
  ENDMETHOD.

  METHOD get_result1.
    IF mv_result1 IS INITIAL.
      mv_result1 = |{ solve( 3 ) }|.
    ENDIF.
    rv_result = mv_result1.
  ENDMETHOD.

  METHOD get_result2.
    IF mv_result2 IS INITIAL.
      mv_result2 = |{ solve( 4 ) }|.
    ENDIF.
    rv_result = mv_result2.
  ENDMETHOD.
ENDCLASS.
