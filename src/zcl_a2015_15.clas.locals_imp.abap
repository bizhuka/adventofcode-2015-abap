CLASS lcl_output DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun_out.
    DATA text TYPE string.
ENDCLASS.
CLASS lcl_output IMPLEMENTATION.
  METHOD if_oo_adt_classrun_out~write.
    text = text && CONV string( data ) && `;`.
    output = me.
  ENDMETHOD.
  METHOD if_oo_adt_classrun_out~get.
    IF data IS SUPPLIED.
      if_oo_adt_classrun_out~write( data = data ).
    ENDIF.
    output = text.
    CLEAR text.
  ENDMETHOD.
ENDCLASS.
