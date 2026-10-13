CLASS zcl_a2015_11 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS init REDEFINITION.
    METHODS get_result1 REDEFINITION.
    METHODS get_result2 REDEFINITION.
    CLASS-METHODS next_password
      IMPORTING iv_password        TYPE string
      RETURNING VALUE(rv_password) TYPE string.
    CLASS-METHODS is_valid
      IMPORTING iv_password     TYPE string
      RETURNING VALUE(rv_valid) TYPE abap_bool.
  PRIVATE SECTION.
    TYPES ty_password TYPE c LENGTH 8.
    CONSTANTS alphabet TYPE string VALUE 'abcdefghijklmnopqrstuvwxyz'.
    DATA mv_input TYPE string VALUE 'hepxcrrq'.
    CLASS-METHODS increment CHANGING cv_password TYPE ty_password.
ENDCLASS.

CLASS zcl_a2015_11 IMPLEMENTATION.
  METHOD init.
    READ TABLE it_input INDEX 1 INTO mv_input.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = next_password( mv_input ).
  ENDMETHOD.

  METHOD get_result2.
    rv_result = next_password( next_password( mv_input ) ).
  ENDMETHOD.

  METHOD increment.
    DO 8 TIMES.
      DATA(lv_pos) = 8 - sy-index.
      IF cv_password+lv_pos(1) = 'z'.
        cv_password+lv_pos(1) = 'a'.
      ELSE.
        FIND FIRST OCCURRENCE OF cv_password+lv_pos(1)
          IN alphabet MATCH OFFSET DATA(lv_letter).
        lv_letter = lv_letter + 1.
        cv_password+lv_pos(1) = alphabet+lv_letter(1).
        EXIT.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD next_password.
    IF strlen( iv_password ) <> 8 OR iv_password CN alphabet.
      RETURN.
    ENDIF.
    DATA lv_password TYPE ty_password.
    lv_password = iv_password.
    DO.
      increment( CHANGING cv_password = lv_password ).
      " Skip every suffix under the first forbidden letter.
      DO 8 TIMES.
        DATA(lv_pos) = sy-index - 1.
        IF lv_password+lv_pos(1) CA 'iol'.
          FIND FIRST OCCURRENCE OF lv_password+lv_pos(1)
            IN alphabet MATCH OFFSET DATA(lv_letter).
          lv_letter = lv_letter + 1.
          lv_password+lv_pos(1) = alphabet+lv_letter(1).
          lv_pos = lv_pos + 1.
          WHILE lv_pos < 8.
            lv_password+lv_pos(1) = 'a'.
            lv_pos = lv_pos + 1.
          ENDWHILE.
          EXIT.
        ENDIF.
      ENDDO.
      IF is_valid( CONV string( lv_password ) ) = abap_true.
        rv_password = lv_password.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD is_valid.
    IF strlen( iv_password ) <> 8 OR iv_password CN alphabet
       OR iv_password CA 'iol'.
      RETURN.
    ENDIF.
    DATA(lv_straight) = abap_false.
    DO 6 TIMES.
      DATA(lv_pos) = sy-index - 1.
      IF alphabet CS iv_password+lv_pos(3).
        lv_straight = abap_true.
        EXIT.
      ENDIF.
    ENDDO.
    CHECK lv_straight = abap_true.
    DATA lv_first_pair TYPE c LENGTH 1.
    lv_pos = 0.
    WHILE lv_pos < 7.
      DATA(lv_next) = lv_pos + 1.
      IF iv_password+lv_pos(1) = iv_password+lv_next(1).
        IF lv_first_pair IS INITIAL.
          lv_first_pair = iv_password+lv_pos(1).
        ELSEIF lv_first_pair <> iv_password+lv_pos(1).
          rv_valid = abap_true.
          RETURN.
        ENDIF.
        lv_pos = lv_pos + 2.
      ELSE.
        lv_pos = lv_pos + 1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.


