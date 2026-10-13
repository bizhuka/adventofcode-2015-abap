CLASS zcl_a2015_18 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.

  PRIVATE SECTION.
    DATA mt_grid TYPE string_table.

    METHODS simulate
      IMPORTING iv_stuck_corners  TYPE abap_bool DEFAULT abap_false
                iv_steps          TYPE i DEFAULT 100
      RETURNING VALUE(rv_result) TYPE string.
ENDCLASS.

CLASS zcl_a2015_18 IMPLEMENTATION.
  METHOD init.
    mt_grid = VALUE #(
      FOR lv_line IN it_input
      WHERE ( table_line IS NOT INITIAL )
      ( lv_line ) ).
  ENDMETHOD.

  METHOD get_result1.
    rv_result = simulate( ).
  ENDMETHOD.

  METHOD simulate.
    " Work on a copy so both parts and repeated calls start from the original input.
    DATA(lt_grid) = mt_grid.
    DATA(lv_row_count) = lines( lt_grid ).

    IF lv_row_count = 0.
      rv_result = `0`.
      RETURN.
    ENDIF.

    " Pad to a common width and add an off-cell border for safe neighbor access.
    DATA(lv_width) = REDUCE i(
      INIT lv_max = 0
      FOR lv_line IN lt_grid
      NEXT lv_max = nmax( val1 = lv_max
                         val2 = strlen( lv_line ) ) ).
    DATA(lv_stride) = lv_width + 2.
    DATA(lv_border) = repeat( val = `.`
                             occ = lv_stride ).

    DATA lt_widths TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lt_buffer_rows TYPE string_table.

    " Part 2 requires the corners to be on before the first neighbor count.
    LOOP AT lt_grid ASSIGNING FIELD-SYMBOL(<lv_corner_row>).
      CHECK iv_stuck_corners = abap_true.
      CHECK sy-tabix = 1 OR sy-tabix = lv_row_count.

      DATA(lv_last_column) = strlen( <lv_corner_row> ) - 1.
      CHECK lv_last_column >= 0.

      REPLACE SECTION OFFSET 0 LENGTH 1 OF <lv_corner_row> WITH '#'.
      REPLACE SECTION OFFSET lv_last_column LENGTH 1 OF <lv_corner_row> WITH '#'.
    ENDLOOP.

    " Flatten the padded rows; retain original widths to update only real cells.
    INSERT lv_border INTO TABLE lt_buffer_rows.

    LOOP AT lt_grid ASSIGNING FIELD-SYMBOL(<lv_row>).
      DATA(lv_row_width) = strlen( <lv_row> ).
      INSERT lv_row_width INTO TABLE lt_widths.

      INSERT `.` && <lv_row> && repeat( val = `.`
                                       occ = lv_width - lv_row_width + 1 )
        INTO TABLE lt_buffer_rows.
    ENDLOOP.

    INSERT lv_border INTO TABLE lt_buffer_rows.

    DATA(lv_buffer) = concat_lines_of( table = lt_buffer_rows ).

    DO iv_steps TIMES.
      lt_buffer_rows = VALUE #( ( lv_border ) ).
      LOOP AT lt_widths ASSIGNING FIELD-SYMBOL(<lv_row_width>).
        DATA(lv_next_row) = `.`.
        DATA(lv_row_index) = sy-tabix.
        DATA(lv_offset) = lv_row_index * lv_stride + 1.
        DATA(lv_above) = lv_offset - lv_stride.
        DATA(lv_below) = lv_offset + lv_stride.

        " Each sum covers three vertical cells; the initial left column is the border.
        DATA(lv_left) = 0.
        DATA(lv_center) =
            COND i( WHEN lv_buffer+lv_above(1) = '#' THEN 1 ELSE 0 )
          + COND i( WHEN lv_buffer+lv_offset(1) = '#' THEN 1 ELSE 0 )
          + COND i( WHEN lv_buffer+lv_below(1) = '#' THEN 1 ELSE 0 ).

        DO <lv_row_width> TIMES.
          DATA(lv_above_right) = lv_above + 1.
          DATA(lv_current_right) = lv_offset + 1.
          DATA(lv_below_right) = lv_below + 1.

          DATA(lv_right) =
              COND i( WHEN lv_buffer+lv_above_right(1) = '#' THEN 1 ELSE 0 )
            + COND i( WHEN lv_buffer+lv_current_right(1) = '#' THEN 1 ELSE 0 )
            + COND i( WHEN lv_buffer+lv_below_right(1) = '#' THEN 1 ELSE 0 ).
          DATA(lv_is_on) = COND i( WHEN lv_buffer+lv_offset(1) = '#' THEN 1 ELSE 0 ).

          " The three columns cover nine cells; exclude the current cell itself.
          DATA(lv_neighbors) = lv_left + lv_center + lv_right - lv_is_on.

          " Stuck corners override the normal survival and birth rules on every step.
          DATA(lv_next_cell) = COND string(
            WHEN iv_stuck_corners = abap_true
              AND ( lv_row_index = 1 OR lv_row_index = lv_row_count )
              AND ( sy-index = 1 OR sy-index = <lv_row_width> )
              THEN '#'
            WHEN lv_neighbors = 3 OR ( lv_is_on = 1 AND lv_neighbors = 2 )
              THEN '#'
            ELSE '.' ).

          " Build one short row instead of copying the whole grid per cell.
          lv_next_row = lv_next_row && lv_next_cell.

          " Slide right, reusing two column sums instead of recounting all neighbors.
          lv_left = lv_center.
          lv_center = lv_right.
          lv_above = lv_above_right.
          lv_offset = lv_current_right.
          lv_below = lv_below_right.
        ENDDO.
        APPEND lv_next_row && repeat( val = `.` occ = lv_width - <lv_row_width> + 1 ) TO lt_buffer_rows.
      ENDLOOP.
      APPEND lv_border TO lt_buffer_rows.
      DATA(lv_next) = concat_lines_of( table = lt_buffer_rows ).
      " Publish the complete next state only after every real cell has been updated.
      IF lv_buffer = lv_next.
        EXIT.
      ENDIF.
      lv_buffer = lv_next.
    ENDDO.

    " Padding remains off, so counting the whole buffer counts only real lights.
    FIND ALL OCCURRENCES OF '#' IN lv_buffer MATCH COUNT DATA(lv_lights).
    rv_result = |{ lv_lights }|.
  ENDMETHOD.

  METHOD get_result2.
    rv_result = simulate( iv_stuck_corners = abap_true ).
  ENDMETHOD.
ENDCLASS.


