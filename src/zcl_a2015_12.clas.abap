CLASS zcl_a2015_12  DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_node,
        sum    TYPE zcl_a2015_base=>ty_big_int,
        is_red TYPE abap_bool,
      END OF ty_node.

    DATA:
      mv_input TYPE string,
      mv_pos   TYPE i,
      mv_len   TYPE i.

    METHODS:
      parse_node   RETURNING VALUE(rs_node) TYPE ty_node,
      parse_object RETURNING VALUE(rs_node) TYPE ty_node,
      parse_array  RETURNING VALUE(rs_node) TYPE ty_node,
      parse_string RETURNING VALUE(rs_node) TYPE ty_node,
      parse_number RETURNING VALUE(rs_node) TYPE ty_node,
      skip_whitespace.
ENDCLASS.



CLASS zcl_a2015_12 IMPLEMENTATION.
  METHOD get_result1.
    FIND ALL OCCURRENCES OF REGEX '-?\d+' IN mv_input RESULTS DATA(lt_matches).
    rv_result = REDUCE #( INIT sum TYPE zcl_a2015_base=>ty_big_int
                          FOR ls_match IN lt_matches
                          NEXT sum = sum + CONV zcl_a2015_base=>ty_big_int( substring( val = mv_input off = ls_match-offset len = ls_match-length ) ) ).
  ENDMETHOD.

  METHOD get_result2.
    mv_pos = 0.
    mv_len = strlen( mv_input ).
    rv_result = parse_node( )-sum.
  ENDMETHOD.

  METHOD skip_whitespace.
    WHILE mv_pos < mv_len.
      DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
      IF lv_char CA cl_abap_char_utilities=>cr_lf OR lv_char CA cl_abap_char_utilities=>horizontal_tab OR lv_char CA cl_abap_char_utilities=>newline OR lv_char = ` `.
        mv_pos = mv_pos + 1.
      ELSE.
        RETURN.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD parse_node.
    skip_whitespace( ).
    CHECK mv_pos < mv_len.
    DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
    CASE lv_char.
      WHEN '{'.
        rs_node = parse_object( ).
      WHEN '['.
        rs_node = parse_array( ).
      WHEN '"'.
        rs_node = parse_string( ).
      WHEN OTHERS.
        IF lv_char CA '-0123456789'.
          rs_node = parse_number( ).
        ELSEIF mv_pos + 4 <= mv_len AND substring( val = mv_input off = mv_pos len = 4 ) = 'null'.
          mv_pos = mv_pos + 4.
        ELSEIF mv_pos + 4 <= mv_len AND substring( val = mv_input off = mv_pos len = 4 ) = 'true'.
          mv_pos = mv_pos + 4.
        ELSEIF mv_pos + 5 <= mv_len AND substring( val = mv_input off = mv_pos len = 5 ) = 'false'.
          mv_pos = mv_pos + 5.
        ELSE.
          mv_pos = mv_pos + 1. " Failsafe
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD parse_object.
    mv_pos = mv_pos + 1. " skip {
    DATA(lv_is_red) = abap_false.
    DATA(lv_sum) = CONV zcl_a2015_base=>ty_big_int( 0 ).

    WHILE mv_pos < mv_len.
      skip_whitespace( ).
      CHECK mv_pos < mv_len.
      DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
      IF lv_char = '}'.
        mv_pos = mv_pos + 1.
        IF lv_is_red = abap_false.
          rs_node-sum = lv_sum.
        ENDIF.
        RETURN.
      ENDIF.
      IF lv_char = ','.
        mv_pos = mv_pos + 1.
        CONTINUE.
      ENDIF.

      " Expect a key
      IF lv_char = '"'.
        parse_string( ). " Consume string key
      ELSE.
        mv_pos = mv_pos + 1.
        CONTINUE.
      ENDIF.

      skip_whitespace( ).
      CHECK mv_pos < mv_len.
      IF substring( val = mv_input off = mv_pos len = 1 ) = ':'.
        mv_pos = mv_pos + 1.
      ENDIF.

      DATA(ls_val) = parse_node( ).
      IF ls_val-is_red = abap_true.
        lv_is_red = abap_true.
      ENDIF.
      lv_sum = lv_sum + ls_val-sum.

    ENDWHILE.
  ENDMETHOD.

  METHOD parse_array.
    mv_pos = mv_pos + 1. " skip [
    WHILE mv_pos < mv_len.
      skip_whitespace( ).
      CHECK mv_pos < mv_len.
      DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
      IF lv_char = ']'.
        mv_pos = mv_pos + 1.
        RETURN.
      ENDIF.
      IF lv_char = ','.
        mv_pos = mv_pos + 1.
        CONTINUE.
      ENDIF.
      DATA(ls_val) = parse_node( ).
      rs_node-sum = rs_node-sum + ls_val-sum.
    ENDWHILE.
  ENDMETHOD.

  METHOD parse_string.
    mv_pos = mv_pos + 1.
    DATA(lv_start) = mv_pos.
    WHILE mv_pos < mv_len.
      DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
      IF lv_char = '\'.
        mv_pos = mv_pos + 2.
        CONTINUE.
      ENDIF.
      IF lv_char = '"'.
        DATA(lv_str_len) = mv_pos - lv_start.
        DATA(lv_str) = substring( val = mv_input off = lv_start len = lv_str_len ).
        IF lv_str = `red`.
          rs_node-is_red = abap_true.
        ENDIF.
        mv_pos = mv_pos + 1.
        RETURN.
      ENDIF.
      mv_pos = mv_pos + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD parse_number.
    DATA(lv_start) = mv_pos.
    WHILE mv_pos < mv_len.
      DATA(lv_char) = substring( val = mv_input off = mv_pos len = 1 ).
      IF lv_char CN '-0123456789'.
        EXIT.
      ENDIF.
      mv_pos = mv_pos + 1.
    ENDWHILE.
    DATA(lv_num_len) = mv_pos - lv_start.
    DATA(lv_num_str) = substring( val = mv_input off = lv_start len = lv_num_len ).
    TRY.
        rs_node-sum = CONV #( lv_num_str ).
      CATCH cx_sy_conversion_no_number.
    ENDTRY.
  ENDMETHOD.

  METHOD init.
    mv_input = REDUCE #( INIT str = ``
                         FOR ls_line IN it_input
                         NEXT str = str && ls_line ).
  ENDMETHOD.

ENDCLASS.
