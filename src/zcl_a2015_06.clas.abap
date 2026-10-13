CLASS zcl_a2015_06 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS init REDEFINITION.
    METHODS get_result1 REDEFINITION.
    METHODS get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_command,
             action TYPE i,
             x1 TYPE i,
             y1 TYPE i,
             x2 TYPE i,
             y2 TYPE i,
           END OF ty_command,
           BEGIN OF ty_cell,
             light TYPE i,
             brightness TYPE i,
           END OF ty_cell.
    TYPES tt_boundaries TYPE SORTED TABLE OF i WITH UNIQUE KEY table_line.
    DATA mt_commands TYPE STANDARD TABLE OF ty_command WITH EMPTY KEY.
    DATA mt_x TYPE tt_boundaries.
    DATA mt_y TYPE tt_boundaries.
    DATA mv_result1 TYPE string.
    DATA mv_result2 TYPE string.
    METHODS solve.
ENDCLASS.

CLASS zcl_a2015_06 IMPLEMENTATION.
  METHOD init.
    CLEAR: mt_commands, mt_x, mt_y, mv_result1, mv_result2.
    DATA(lv_content) = concat_lines_of( table = it_input sep = cl_abap_char_utilities=>newline ).
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_content WITH cl_abap_char_utilities=>newline.
    SPLIT lv_content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_input).
    LOOP AT lt_input INTO DATA(lv_line).
      FIND REGEX `^(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)$` IN lv_line
        SUBMATCHES DATA(lv_action) DATA(lv_x1) DATA(lv_y1) DATA(lv_x2) DATA(lv_y2).
      CHECK sy-subrc = 0.
      DATA(ls_command) = VALUE ty_command(
        action = SWITCH #( lv_action WHEN 'turn on' THEN 1 WHEN 'turn off' THEN -1 ELSE 2 )
        x1 = lv_x1 y1 = lv_y1 x2 = lv_x2 y2 = lv_y2 ).
      CHECK ls_command-x1 <= ls_command-x2 AND ls_command-y1 <= ls_command-y2
        AND ls_command-x2 < 1000 AND ls_command-y2 < 1000.
      " Cells between adjacent instruction boundaries always share the same state.
      ls_command-x2 += 1.
      ls_command-y2 += 1.
      INSERT ls_command-x1 INTO TABLE mt_x.
      INSERT ls_command-x2 INTO TABLE mt_x.
      INSERT ls_command-y1 INTO TABLE mt_y.
      INSERT ls_command-y2 INTO TABLE mt_y.
      APPEND ls_command TO mt_commands.
    ENDLOOP.
    LOOP AT mt_commands ASSIGNING FIELD-SYMBOL(<ls_command>).
      <ls_command>-x1 = line_index( mt_x[ table_line = <ls_command>-x1 ] ).
      <ls_command>-x2 = line_index( mt_x[ table_line = <ls_command>-x2 ] ) - 1.
      <ls_command>-y1 = line_index( mt_y[ table_line = <ls_command>-y1 ] ).
      <ls_command>-y2 = line_index( mt_y[ table_line = <ls_command>-y2 ] ) - 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD solve.
    CHECK mv_result1 IS INITIAL.
    DATA(lv_columns) = nmax( val1 = 0 val2 = lines( mt_x ) - 1 ).
    DATA(lv_rows) = nmax( val1 = 0 val2 = lines( mt_y ) - 1 ).
    TYPES ltt_cells TYPE STANDARD TABLE OF ty_cell WITH EMPTY KEY.
    DATA(lt_cells) = VALUE ltt_cells( FOR lv_index = 1 UNTIL lv_index > lv_columns * lv_rows ( ) ).
    LOOP AT mt_commands ASSIGNING FIELD-SYMBOL(<ls_command>).
      DO <ls_command>-y2 - <ls_command>-y1 + 1 TIMES.
        DATA(lv_row) = <ls_command>-y1 + sy-index - 1.
        DATA(lv_from) = ( lv_row - 1 ) * lv_columns + <ls_command>-x1.
        DATA(lv_to) = ( lv_row - 1 ) * lv_columns + <ls_command>-x2.
        CASE <ls_command>-action.
          WHEN 1.
            LOOP AT lt_cells ASSIGNING FIELD-SYMBOL(<ls_cell>) FROM lv_from TO lv_to.
              <ls_cell>-light = 1.
              <ls_cell>-brightness += 1.
            ENDLOOP.
          WHEN -1.
            LOOP AT lt_cells ASSIGNING <ls_cell> FROM lv_from TO lv_to.
              <ls_cell>-light = 0.
              <ls_cell>-brightness = nmax( val1 = 0 val2 = <ls_cell>-brightness - 1 ).
            ENDLOOP.
          WHEN 2.
            LOOP AT lt_cells ASSIGNING <ls_cell> FROM lv_from TO lv_to.
              <ls_cell>-light = 1 - <ls_cell>-light.
              <ls_cell>-brightness += 2.
            ENDLOOP.
        ENDCASE.
      ENDDO.
    ENDLOOP.
    DATA lv_lights TYPE i.
    DATA lv_brightness TYPE i.
    DO lv_rows TIMES.
      lv_row = sy-index.
      DATA(lv_height) = mt_y[ lv_row + 1 ] - mt_y[ lv_row ].
      lv_from = ( lv_row - 1 ) * lv_columns + 1.
      lv_to = lv_row * lv_columns.
      DATA(lv_column) = 1.
      LOOP AT lt_cells ASSIGNING <ls_cell> FROM lv_from TO lv_to.
        DATA(lv_area) = lv_height * ( mt_x[ lv_column + 1 ] - mt_x[ lv_column ] ).
        lv_lights += <ls_cell>-light * lv_area.
        lv_brightness += <ls_cell>-brightness * lv_area.
        lv_column += 1.
      ENDLOOP.
    ENDDO.
    mv_result1 = lv_lights.
    mv_result2 = lv_brightness.
  ENDMETHOD.

  METHOD get_result1.
    solve( ).
    rv_result = mv_result1.
  ENDMETHOD.

  METHOD get_result2.
    solve( ).
    rv_result = mv_result2.
  ENDMETHOD.
ENDCLASS.
