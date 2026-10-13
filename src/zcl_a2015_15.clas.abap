CLASS zcl_a2015_15 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_properties,
             capacity TYPE ty_big_int,
             durability TYPE ty_big_int,
             flavor TYPE ty_big_int,
             texture TYPE ty_big_int,
             calories TYPE ty_big_int,
           END OF ty_properties.
    DATA mt_ingredients TYPE STANDARD TABLE OF ty_properties WITH EMPTY KEY.
    DATA mv_best TYPE ty_big_int.
    DATA mv_best500 TYPE ty_big_int.
    DATA mv_solved TYPE abap_bool.
    METHODS solve.
    METHODS recipes IMPORTING iv_index TYPE i iv_remaining TYPE i
                              is_total TYPE ty_properties.
ENDCLASS.

CLASS zcl_a2015_15 IMPLEMENTATION.
  METHOD init.
    CLEAR: mt_ingredients, mv_best, mv_best500, mv_solved.
    LOOP AT it_input INTO DATA(lv_line).
      FIND REGEX '^([A-Za-z]+): capacity (-?[0-9]+), durability (-?[0-9]+), flavor (-?[0-9]+), texture (-?[0-9]+), calories (-?[0-9]+)'
        IN lv_line SUBMATCHES DATA(lv_name) DATA(lv_capacity) DATA(lv_durability)
          DATA(lv_flavor) DATA(lv_texture) DATA(lv_calories).
      CHECK sy-subrc = 0.
      APPEND VALUE #( capacity = CONV #( lv_capacity ) durability = CONV #( lv_durability )
                      flavor = CONV #( lv_flavor ) texture = CONV #( lv_texture )
                      calories = CONV #( lv_calories ) ) TO mt_ingredients.
    ENDLOOP.
  ENDMETHOD.

  METHOD solve.
    CHECK mv_solved = abap_false.
    CLEAR: mv_best, mv_best500.
    IF mt_ingredients IS NOT INITIAL.
      recipes( iv_index = 1 iv_remaining = 100 is_total = VALUE #( ) ).
    ENDIF.
    mv_solved = abap_true.
  ENDMETHOD.

  METHOD recipes.
    DATA(ls_ingredient) = mt_ingredients[ iv_index ].
    DATA(lv_last) = xsdbool( iv_index = lines( mt_ingredients ) ).
    DATA(lv_amount) = COND i( WHEN lv_last = abap_true THEN iv_remaining ELSE 0 ).
    WHILE lv_amount <= iv_remaining.
      DATA(ls_total) = VALUE ty_properties(
        capacity = is_total-capacity + lv_amount * ls_ingredient-capacity
        durability = is_total-durability + lv_amount * ls_ingredient-durability
        flavor = is_total-flavor + lv_amount * ls_ingredient-flavor
        texture = is_total-texture + lv_amount * ls_ingredient-texture
        calories = is_total-calories + lv_amount * ls_ingredient-calories ).
      IF lv_last = abap_true.
        DATA(lv_score) = nmax( val1 = ls_total-capacity val2 = 0 ) *
                         nmax( val1 = ls_total-durability val2 = 0 ) *
                         nmax( val1 = ls_total-flavor val2 = 0 ) *
                         nmax( val1 = ls_total-texture val2 = 0 ).
        mv_best = nmax( val1 = mv_best val2 = lv_score ).
        IF ls_total-calories = 500.
          mv_best500 = nmax( val1 = mv_best500 val2 = lv_score ).
        ENDIF.
        EXIT.
      ELSE.
        recipes( iv_index = iv_index + 1 iv_remaining = iv_remaining - lv_amount is_total = ls_total ).
      ENDIF.
      lv_amount = lv_amount + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_result1.
    solve( ).
    rv_result = |{ mv_best }|.
  ENDMETHOD.
  METHOD get_result2.
    solve( ).
    rv_result = |{ mv_best500 }|.
  ENDMETHOD.
ENDCLASS.
