CLASS zcl_a2015_run_all DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_a2015_run_all IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_children TYPE string_table.

    DATA lt_children_sap TYPE seor_inheritance_keys.
    CALL FUNCTION 'SEO_CLASS_GET_ALL_SUBS'
      EXPORTING
        clskey             = VALUE seoclskey( clsname = 'ZCL_A2015_BASE' )
        version            = '1' " Active classes, including indirect subclasses
      IMPORTING
        inhkeys            = lt_children_sap
      EXCEPTIONS
        class_not_existing = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      out->write( `Cannot discover subclasses of ZCL_A2015_BASE.` ).
      RETURN.
    ENDIF.

    SORT lt_children_sap BY clsname.
    DELETE ADJACENT DUPLICATES FROM lt_children_sap COMPARING clsname.
    lt_children = VALUE #( FOR <lfs_line> IN lt_children_sap ( |{ <lfs_line>-clsname }| ) ).

    SORT lt_children.
    IF lt_children IS INITIAL.
      out->write( `No subclasses of ZCL_A2015_BASE found.` ).
      RETURN.
    ENDIF.

    TYPES: BEGIN OF lty_log,
             class_name      TYPE string,
             elapsed_seconds TYPE tzntstmpl,
             status          TYPE string,
             error           TYPE string,
           END OF lty_log.
    DATA lt_log TYPE STANDARD TABLE OF lty_log WITH EMPTY KEY.
    DATA lo_child TYPE REF TO zcl_a2015_base.
    DATA lv_started TYPE timestampl.
    DATA lv_finished TYPE timestampl.

    out->write( `Each duration includes class creation, input loading, initialization and both parts.` ).

    LOOP AT lt_children ASSIGNING FIELD-SYMBOL(<lv_child>).
      DATA(ls_log) = VALUE lty_log( class_name = <lv_child> status = `OK` ).
      CLEAR lo_child.
      out->write( |--- { <lv_child> } ---| ).

      " Keep each child's existing console execution and puzzle output.
      " Start before creation so the log also includes constructor/class loading costs.
      GET TIME STAMP FIELD lv_started.
      TRY.
          CREATE OBJECT lo_child TYPE (<lv_child>).
          lo_child->if_oo_adt_classrun~main( out ).
        CATCH cx_root INTO DATA(lx_error).
          ls_log-status = `ERROR`.
          ls_log-error = lx_error->get_text( ).
          out->write( |ERROR: { ls_log-error }| ).
      ENDTRY.
      GET TIME STAMP FIELD lv_finished.
      CLEAR lo_child.

      " Wall-clock seconds include database/file access as well as calculation.
      TRY.
          ls_log-elapsed_seconds = cl_abap_tstmp=>subtract(
            tstmp1 = lv_finished
            tstmp2 = lv_started ).
          out->write( |Elapsed: { ls_log-elapsed_seconds DECIMALS = 6 NUMBER = RAW } s ({ ls_log-status })| ).
        CATCH cx_root INTO DATA(lx_timer).
          ls_log-status = `ERROR`.
          ls_log-error = |Timing failed: { lx_timer->get_text( ) }|.
          out->write( ls_log-error ).
      ENDTRY.
      APPEND ls_log TO lt_log.
    ENDLOOP.

    " Show the slowest classes first to establish a baseline for later optimization.
    SORT lt_log BY elapsed_seconds DESCENDING class_name ASCENDING.
    out->write( `Execution summary (slowest first; elapsed_seconds is in seconds)` ).
    out->write( lt_log ).
  ENDMETHOD.
ENDCLASS.

