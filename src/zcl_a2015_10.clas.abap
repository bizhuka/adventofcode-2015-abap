CLASS zcl_a2015_10 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION,
      look_and_say_length
        IMPORTING iv_count         TYPE i
        RETURNING VALUE(rv_length) TYPE i.
  PRIVATE SECTION.
    DATA:
      mt_input TYPE string_table.
    METHODS:
      generate_next_sequence
        IMPORTING iv_sequence        TYPE string
        RETURNING VALUE(rv_sequence) TYPE string.
ENDCLASS.

CLASS zcl_a2015_10 IMPLEMENTATION.

  METHOD init.
    mt_input = it_input[].
  ENDMETHOD.

  METHOD get_result1.
    rv_result = look_and_say_length( 40 ).
  ENDMETHOD.

  METHOD get_result2.
    rv_result = look_and_say_length( 50 ).
  ENDMETHOD.

  METHOD look_and_say_length.
    DATA(lv_sequence) = mt_input[ 1 ].
    DO iv_count TIMES.
      lv_sequence = generate_next_sequence( lv_sequence ).
    ENDDO.
    rv_length = strlen( lv_sequence ).
  ENDMETHOD.

  METHOD generate_next_sequence.
    DATA(lv_len) = strlen( iv_sequence ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    DATA(lv_prev)  = iv_sequence(1).
    DATA(lv_count) = 1.
    DATA lt_chunks TYPE string_table.
    DATA lv_chunk TYPE string.

    DO lv_len - 1 TIMES.
      DATA(lv_idx)  = sy-index.
      DATA(lv_char) = iv_sequence+lv_idx(1).

      IF lv_char = lv_prev.
        lv_count = lv_count + 1.
      ELSE.
        lv_chunk = lv_chunk && lv_count && lv_prev.
        " Bound repeated string copies, then join the chunks once.
        IF strlen( lv_chunk ) >= 4096.
          APPEND lv_chunk TO lt_chunks.
          CLEAR lv_chunk.
        ENDIF.
        lv_prev     = lv_char.
        lv_count    = 1.
      ENDIF.
    ENDDO.

    APPEND lv_chunk && lv_count && lv_prev TO lt_chunks.
    rv_sequence = concat_lines_of( table = lt_chunks ).
  ENDMETHOD.

ENDCLASS.
