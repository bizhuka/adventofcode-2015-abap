CLASS zcl_a2015_17 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_liters TYPE i VALUE 150.
    METHODS: init REDEFINITION,
             get_result1 REDEFINITION,
             get_result2 REDEFINITION.
  PRIVATE SECTION.
    DATA mt_containers TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA mv_combinations TYPE ty_big_int.
    DATA mv_min_containers TYPE i.
    DATA mv_min_combinations TYPE ty_big_int.
    METHODS solve.
    METHODS count_combinations IMPORTING iv_index TYPE i iv_remaining TYPE i
                                        iv_used TYPE i DEFAULT 0.
ENDCLASS.

CLASS zcl_a2015_17 IMPLEMENTATION.
  METHOD init.
    CLEAR: mt_containers, mv_combinations.
    LOOP AT it_input INTO DATA(lv_line).
      CONDENSE lv_line.
      CHECK lv_line IS NOT INITIAL.
      APPEND CONV i( lv_line ) TO mt_containers.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_combinations.
    IF iv_remaining = 0.
      mv_combinations = mv_combinations + 1.
      mv_min_combinations = COND #( WHEN iv_used < mv_min_containers THEN 1
                                    WHEN iv_used = mv_min_containers THEN mv_min_combinations + 1
                                    ELSE mv_min_combinations ).
      mv_min_containers = nmin( val1 = mv_min_containers val2 = iv_used ).
      RETURN.
    ENDIF.
    CHECK iv_remaining > 0 AND iv_index <= lines( mt_containers ).
    count_combinations( iv_index = iv_index + 1 iv_remaining = iv_remaining iv_used = iv_used ).
    count_combinations( iv_index = iv_index + 1
                        iv_remaining = iv_remaining - mt_containers[ iv_index ]
                        iv_used = iv_used + 1 ).
  ENDMETHOD.

  METHOD solve.
    CLEAR: mv_combinations, mv_min_combinations.
    mv_min_containers = lines( mt_containers ) + 1.
    count_combinations( iv_index = 1 iv_remaining = mv_liters ).
  ENDMETHOD.

  METHOD get_result1.
    solve( ).
    rv_result = |{ mv_combinations }|.
  ENDMETHOD.

  METHOD get_result2.
    solve( ).
    rv_result = |{ mv_min_combinations }|.
  ENDMETHOD.
ENDCLASS.
