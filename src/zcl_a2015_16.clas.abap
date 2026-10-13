CLASS zcl_a2015_16 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    DATA mv_result TYPE string.
    DATA mv_result2 TYPE string.
ENDCLASS.

CLASS zcl_a2015_16 IMPLEMENTATION.
  METHOD init.
    TYPES: BEGIN OF ty_property,
             name TYPE string,
             amount TYPE i,
           END OF ty_property.
    DATA lt_reference TYPE HASHED TABLE OF ty_property WITH UNIQUE KEY name.
    lt_reference = VALUE #( ( name = 'children' amount = 3 )
                            ( name = 'cats' amount = 7 )
                            ( name = 'samoyeds' amount = 2 )
                            ( name = 'pomeranians' amount = 3 )
                            ( name = 'akitas' amount = 0 )
                            ( name = 'vizslas' amount = 0 )
                            ( name = 'goldfish' amount = 5 )
                            ( name = 'trees' amount = 3 )
                            ( name = 'cars' amount = 2 )
                            ( name = 'perfumes' amount = 1 ) ).
    CLEAR: mv_result, mv_result2.
    LOOP AT it_input INTO DATA(lv_line).
      FIND REGEX '^Sue ([0-9]+): (.*)' IN lv_line
        SUBMATCHES DATA(lv_number) DATA(lv_properties).
      CHECK sy-subrc = 0.
      SPLIT lv_properties AT ',' INTO TABLE DATA(lt_properties).
      DATA(lv_matches) = abap_true.
      DATA(lv_matches2) = abap_true.
      LOOP AT lt_properties INTO DATA(lv_property).
        SPLIT lv_property AT ':' INTO DATA(lv_name) DATA(lv_amount).
        CONDENSE: lv_name, lv_amount.
        READ TABLE lt_reference INTO DATA(ls_reference) WITH TABLE KEY name = lv_name.
        IF sy-subrc <> 0.
          CLEAR: lv_matches, lv_matches2.
          EXIT.
        ENDIF.
        DATA(lv_value) = CONV i( lv_amount ).
        IF lv_value <> ls_reference-amount.
          lv_matches = abap_false.
        ENDIF.
        CASE lv_name.
          WHEN 'cats' OR 'trees'.
            IF lv_value <= ls_reference-amount.
              lv_matches2 = abap_false.
            ENDIF.
          WHEN 'pomeranians' OR 'goldfish'.
            IF lv_value >= ls_reference-amount.
              lv_matches2 = abap_false.
            ENDIF.
          WHEN OTHERS.
            IF lv_value <> ls_reference-amount.
              lv_matches2 = abap_false.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      IF lv_matches = abap_true AND mv_result IS INITIAL.
        mv_result = lv_number.
      ENDIF.
      IF lv_matches2 = abap_true AND mv_result2 IS INITIAL.
        mv_result2 = lv_number.
      ENDIF.
      IF mv_result IS NOT INITIAL AND mv_result2 IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = mv_result.
  ENDMETHOD.

  METHOD get_result2.
    rv_result = mv_result2.
  ENDMETHOD.
ENDCLASS.
