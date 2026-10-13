CLASS zcl_a2015_03 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_pos,
        x TYPE i,
        y TYPE i,
      END OF ty_pos,
      " Explicit fields preserve coordinate uniqueness in the local runtime.
      tt_pos TYPE SORTED TABLE OF ty_pos WITH UNIQUE KEY x y,

      BEGIN OF ty_santa,
        x TYPE i,
        y TYPE i,
      END OF ty_santa.

    DATA:
      mv_input TYPE string,
      mt_house TYPE tt_pos.

    METHODS _make_move  IMPORTING iv_direction TYPE char1
                        CHANGING cs_santa     TYPE ty_santa.
ENDCLASS.



CLASS zcl_a2015_03 IMPLEMENTATION.
  METHOD init.
    mv_input = it_input[ 1 ].
  ENDMETHOD.

  METHOD get_result1.
    CLEAR mt_house[].
    DATA ls_santa TYPE ty_santa.

    DO strlen( mv_input ) TIMES.
      DATA(lv_offset) = sy-index - 1.
      _make_move( EXPORTING iv_direction = CONV #( mv_input+lv_offset(1) )
                  CHANGING cs_santa     = ls_santa ).
    ENDDO.

    rv_result = lines( mt_house[] ).
  ENDMETHOD.

  METHOD get_result2.
    CLEAR mt_house[].
    DATA ls_santa TYPE ty_santa.
    DATA ls_robo_santa TYPE ty_santa.

    DO strlen( mv_input ) TIMES.
      DATA(lv_offset) = sy-index - 1.
      IF sy-index MOD 2 = 1.
        _make_move( EXPORTING iv_direction = CONV #( mv_input+lv_offset(1) )
                    CHANGING cs_santa = ls_santa ).
      ELSE.
        _make_move( EXPORTING iv_direction = CONV #( mv_input+lv_offset(1) )
                    CHANGING cs_santa = ls_robo_santa ).
      ENDIF.
    ENDDO.

    rv_result = lines( mt_house[] ).
  ENDMETHOD.

  METHOD _make_move.
    DO 2 TIMES.
      IF sy-index = 2.
        cs_santa-x += SWITCH #( iv_direction WHEN '^' THEN -1
                                             WHEN 'v' THEN +1 ).
        cs_santa-y += SWITCH #( iv_direction WHEN '<' THEN -1
                                             WHEN '>' THEN +1 ).
      ENDIF.

      INSERT VALUE #( x = cs_santa-x
                      y = cs_santa-y ) INTO TABLE mt_house[].
    ENDDO.
  ENDMETHOD.

ENDCLASS.
