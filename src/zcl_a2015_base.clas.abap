CLASS zcl_a2015_base DEFINITION ABSTRACT PUBLIC CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      ty_big_int TYPE int8,
      tt_big_int TYPE STANDARD TABLE OF int8 WITH EMPTY KEY.

    INTERFACES if_oo_adt_classrun.

    DATA:
      mo_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS:
      init        ABSTRACT IMPORTING it_input          TYPE string_table,
      get_result1 ABSTRACT RETURNING VALUE(rv_result)  TYPE string,
      get_result2 ABSTRACT RETURNING VALUE(rv_result)  TYPE string.
  PROTECTED SECTION.
ENDCLASS.



CLASS zcl_a2015_base IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    mo_out = out.

    DATA(lv_class_name) = CAST cl_abap_classdescr( cl_abap_classdescr=>describe_by_object_ref( me ) )->absolute_name.
    DATA(lv_offset)     = strlen( lv_class_name ) - 2.
    DATA(lv_cl_number)  = lv_class_name+lv_offset(2).

    DATA(ls_key) = VALUE wwwdatatab( relid = 'MI' objid = |Z2015_{ lv_cl_number }.TXT| ).
    DATA lt_binary TYPE w3mimetabtype.
    CALL FUNCTION 'WWWDATA_IMPORT'
      EXPORTING key = ls_key
      TABLES mime = lt_binary
      EXCEPTIONS OTHERS = 1.
    ASSERT sy-subrc = 0.

    DATA lv_size_text TYPE c LENGTH 20.
    CALL FUNCTION 'WWWPARAMS_READ'
      EXPORTING relid = ls_key-relid objid = ls_key-objid name = 'filesize'
      IMPORTING value = lv_size_text
      EXCEPTIONS OTHERS = 1.
    ASSERT sy-subrc = 0.

    " W3MIME pads the final 255-byte row; trim it to the actual file size before decoding.
    DATA lv_binary TYPE xstring.
    LOOP AT lt_binary ASSIGNING FIELD-SYMBOL(<ls_binary>).
      CONCATENATE lv_binary <ls_binary>-line INTO lv_binary IN BYTE MODE.
    ENDLOOP.
    DATA(lv_size) = CONV i( lv_size_text ).
    lv_binary = lv_binary(lv_size).
    DATA lv_content TYPE string.
    cl_abap_conv_in_ce=>create( input = lv_binary )->read( IMPORTING data = lv_content ).
    SPLIT lv_content AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(lt_input).
    init( lt_input ).

    DATA(lv_result1) = get_result1( ).
    DATA(lv_result2) = get_result2( ).

    CHECK out IS NOT INITIAL.
    out->write( |Result1 = { lv_result1 }| ).
    out->write( |Result2 = { lv_result2 }| ).
  ENDMETHOD.
ENDCLASS.
