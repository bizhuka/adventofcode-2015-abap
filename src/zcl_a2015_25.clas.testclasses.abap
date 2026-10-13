CLASS ltc_codes DEFINITION DEFERRED.
CLASS zcl_a2015_25 DEFINITION LOCAL FRIENDS ltc_codes.

CLASS ltc_codes DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_25.
    METHODS setup.
    METHODS manual_grid FOR TESTING.
    METHODS iterative_reference FOR TESTING.
    METHODS large_positions FOR TESTING.
    METHODS puzzle_input FOR TESTING.
    METHODS repeat_and_line_endings FOR TESTING.
ENDCLASS.

CLASS ltc_codes IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD manual_grid.
    DATA(lt_rows) = VALUE string_table(
      ( `20151125 18749137 17289845 30943339 10071777 33511524` )
      ( `31916031 21629792 16929656 7726640 15514188 4041754` )
      ( `16080970 8057251 1601130 7981243 11661866 16474243` )
      ( `24592653 32451966 21345942 9380097 10600672 31527494` )
      ( `77061 17552253 28094349 6899651 9250759 31663883` )
      ( `33071741 6796745 25397450 24659492 1534922 27995004` ) ).
    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<lv_row>).
      DATA(lv_row) = sy-tabix.
      SPLIT <lv_row> AT ' ' INTO TABLE DATA(lt_codes).
      LOOP AT lt_codes ASSIGNING FIELD-SYMBOL(<lv_code>).
        DATA(lv_column) = sy-tabix.
        mo_cut->init( VALUE #( ( |Enter the code at row { lv_row }, column { lv_column }.| ) ) ).
        cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = <lv_code> ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD iterative_reference.
    " Walk diagonals and generate successive codes directly, without an index formula.
    DATA(lv_code) = CONV int8( 20151125 ).
    DO 20 TIMES.
      DATA(lv_diagonal) = sy-index.
      DATA(lv_row) = CONV int8( lv_diagonal ).
      DATA(lv_column) = CONV int8( 1 ).
      DO lv_diagonal TIMES.
        cl_abap_unit_assert=>assert_equals(
          act = mo_cut->code_at( iv_row = lv_row iv_column = lv_column ) exp = lv_code ).
        lv_code = ( lv_code * CONV int8( 252533 ) ) MOD CONV int8( 33554393 ).
        lv_row = lv_row - 1.
        lv_column = lv_column + 1.
      ENDDO.
    ENDDO.
  ENDMETHOD.

  METHOD large_positions.
    " Both sequence positions exceed a 32-bit integer; intermediate squares do too.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code_at( iv_row = 1 iv_column = 100000 ) exp = CONV int8( 6523284 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code_at( iv_row = 100000 iv_column = 1 ) exp = CONV int8( 3787769 ) ).
  ENDMETHOD.

  METHOD puzzle_input.
    mo_cut->init( VALUE #( ( `To continue, please consult the code grid in the manual.  Enter the code at row 2978, column 3083.` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2650453` ).
  ENDMETHOD.

  METHOD repeat_and_line_endings.
    mo_cut->init( VALUE #( ( |row 2978,{ cl_abap_char_utilities=>newline }column 3083.| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2650453` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2650453` ).
    mo_cut->init( VALUE #( ( `` ) ( |row 1,{ cl_abap_char_utilities=>cr_lf }column 1.| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `20151125` ).
    mo_cut->init( VALUE #( ( `  row 2,  column 1. ` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `31916031` ).
  ENDMETHOD.
ENDCLASS.
