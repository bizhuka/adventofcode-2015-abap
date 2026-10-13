CLASS zcl_a2015_19 DEFINITION
  PUBLIC INHERITING FROM zcl_a2015_base FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS init REDEFINITION.
    METHODS get_result1 REDEFINITION.
    METHODS get_result2 REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_replacement,
        source TYPE string,
        target TYPE string,
      END OF ty_replacement.
    TYPES tt_replacements TYPE STANDARD TABLE OF ty_replacement WITH EMPTY KEY.
    TYPES tt_molecules TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_growth,
        length    TYPE i,
        potential TYPE i,
      END OF ty_growth,
      BEGIN OF ty_state,
        molecule TYPE string,
        steps    TYPE i,
        estimate TYPE i,
        length   TYPE i,
      END OF ty_state,
      BEGIN OF ty_distance,
        molecule TYPE string,
        steps    TYPE i,
      END OF ty_distance.
    TYPES tt_frontier TYPE SORTED TABLE OF ty_state
      WITH NON-UNIQUE KEY estimate length steps molecule.
    TYPES tt_distances TYPE HASHED TABLE OF ty_distance WITH UNIQUE KEY molecule.

    DATA mt_replacements TYPE tt_replacements.
    DATA mv_molecule TYPE string.

    METHODS parse_line IMPORTING iv_line TYPE string.
    METHODS get_predecessors
      IMPORTING iv_molecule TYPE string
      RETURNING VALUE(rt_molecules) TYPE tt_molecules.
    METHODS get_growth RETURNING VALUE(rs_growth) TYPE ty_growth.
    METHODS get_potential
      IMPORTING iv_molecule TYPE string
      RETURNING VALUE(rv_potential) TYPE i.
    METHODS get_lower_bound
      IMPORTING iv_molecule TYPE string
                is_growth TYPE ty_growth
      RETURNING VALUE(rv_steps) TYPE i.
    METHODS remember_distance
      IMPORTING is_state TYPE ty_state
      CHANGING ct_distances TYPE tt_distances.
ENDCLASS.

CLASS zcl_a2015_19 IMPLEMENTATION.
  METHOD init.
    CLEAR mt_replacements.
    CLEAR mv_molecule.

    LOOP AT it_input ASSIGNING FIELD-SYMBOL(<lv_line>).
      DATA(lv_line) = condense( <lv_line> ).
      CHECK lv_line IS NOT INITIAL.
      parse_line( lv_line ).
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_line.
    IF iv_line NS `=>`.
      mv_molecule = iv_line.
      RETURN.
    ENDIF.

    DATA ls_replacement TYPE ty_replacement.
    SPLIT iv_line AT `=>` INTO ls_replacement-source ls_replacement-target.
    ls_replacement-source = condense( ls_replacement-source ).
    ls_replacement-target = condense( ls_replacement-target ).
    CHECK ls_replacement-source IS NOT INITIAL.
    CHECK ls_replacement-target IS NOT INITIAL.
    INSERT ls_replacement INTO TABLE mt_replacements.
  ENDMETHOD.

  METHOD get_result1.
    DATA lt_molecules TYPE tt_molecules.
    DATA(lv_molecule_length) = strlen( mv_molecule ).

    LOOP AT mt_replacements ASSIGNING FIELD-SYMBOL(<ls_replacement>).
      DATA(lv_source_length) = strlen( <ls_replacement>-source ).
      DATA(lv_positions) = lv_molecule_length - lv_source_length + 1.
      CHECK lv_positions > 0.

      DATA(lv_search) = 0.
      WHILE lv_search < lv_positions.
        DATA(lv_search_text) = substring( val = mv_molecule off = lv_search ).
        FIND FIRST OCCURRENCE OF <ls_replacement>-source IN lv_search_text
          MATCH OFFSET DATA(lv_match).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        DATA(lv_offset) = lv_search + lv_match.
        " Advance one character, retaining overlapping matches such as HH in HHH.
        lv_search = lv_offset + 1.

        DATA(lv_suffix_offset) = lv_offset + lv_source_length.
        DATA(lv_molecule) = substring( val = mv_molecule off = 0 len = lv_offset )
          && <ls_replacement>-target
          && substring( val = mv_molecule off = lv_suffix_offset ).
        INSERT lv_molecule INTO TABLE lt_molecules.
        CHECK sy-subrc = 0.
      ENDWHILE.
    ENDLOOP.

    rv_result = |{ lines( lt_molecules ) }|.
  ENDMETHOD.

  METHOD get_result2.
    DATA lt_frontier TYPE tt_frontier.
    DATA lt_distances TYPE tt_distances.
    DATA(ls_growth) = get_growth( ).
    DATA(lv_e_is_terminal) = REDUCE abap_bool(
      INIT lv_terminal = abap_true
      FOR ls_replacement IN mt_replacements
      NEXT lv_terminal = xsdbool( lv_terminal = abap_true AND ls_replacement-target NS `e` ) ).

    DATA(ls_state) = VALUE ty_state(
      molecule = mv_molecule
      steps = 0
      estimate = get_lower_bound( iv_molecule = mv_molecule is_growth = ls_growth )
      length = strlen( mv_molecule ) ).
    INSERT ls_state INTO TABLE lt_frontier.
    remember_distance( EXPORTING is_state = ls_state CHANGING ct_distances = lt_distances ).

    WHILE lt_frontier IS NOT INITIAL AND lt_frontier[ 1 ]-molecule <> `e`.
      ls_state = lt_frontier[ 1 ].
      DELETE lt_frontier INDEX 1.
      " Explicit table-key reads retain hashed lookup in the local transpiler.
      READ TABLE lt_distances WITH TABLE KEY molecule = ls_state-molecule
        ASSIGNING FIELD-SYMBOL(<ls_current_distance>).
      CHECK sy-subrc = 0.
      CHECK ls_state-steps = <ls_current_distance>-steps.

      DATA(lt_predecessors) = get_predecessors( ls_state-molecule ).
      LOOP AT lt_predecessors ASSIGNING FIELD-SYMBOL(<lv_predecessor>).
        CHECK lv_e_is_terminal = abap_false OR <lv_predecessor> = `e` OR <lv_predecessor> NS `e`.
        DATA(lv_steps) = ls_state-steps + 1.
        READ TABLE lt_distances WITH TABLE KEY molecule = <lv_predecessor>
          ASSIGNING FIELD-SYMBOL(<ls_known_distance>).
        CHECK sy-subrc <> 0 OR lv_steps < <ls_known_distance>-steps.

        DATA(ls_next_state) = VALUE ty_state(
          molecule = <lv_predecessor>
          steps = lv_steps
          estimate = lv_steps + get_lower_bound( iv_molecule = <lv_predecessor> is_growth = ls_growth )
          length = strlen( <lv_predecessor> ) ).
        remember_distance( EXPORTING is_state = ls_next_state CHANGING ct_distances = lt_distances ).
        INSERT ls_next_state INTO TABLE lt_frontier.
      ENDLOOP.
    ENDWHILE.

    rv_result = COND #( WHEN lt_frontier IS INITIAL THEN `No solution`
                       ELSE |{ lt_frontier[ 1 ]-steps }| ) ##NO_TEXT.
  ENDMETHOD.

  METHOD get_predecessors.
    DATA(lv_molecule_length) = strlen( iv_molecule ).
    LOOP AT mt_replacements ASSIGNING FIELD-SYMBOL(<ls_reverse_rule>).
      DATA(lv_target_length) = strlen( <ls_reverse_rule>-target ).
      DATA(lv_positions) = lv_molecule_length - lv_target_length + 1.
      CHECK lv_positions > 0.

      DATA(lv_search) = 0.
      WHILE lv_search < lv_positions.
        DATA(lv_search_text) = substring( val = iv_molecule off = lv_search ).
        FIND FIRST OCCURRENCE OF <ls_reverse_rule>-target IN lv_search_text
          MATCH OFFSET DATA(lv_match).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        DATA(lv_offset) = lv_search + lv_match.
        lv_search = lv_offset + 1.
        DATA(lv_suffix_offset) = lv_offset + lv_target_length.
        DATA(lv_predecessor) = substring( val = iv_molecule off = 0 len = lv_offset )
          && <ls_reverse_rule>-source
          && substring( val = iv_molecule off = lv_suffix_offset ).
        INSERT lv_predecessor INTO TABLE rt_molecules.
        CHECK sy-subrc = 0.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_growth.
    LOOP AT mt_replacements ASSIGNING FIELD-SYMBOL(<ls_growth_rule>).
      rs_growth-length = nmax( val1 = rs_growth-length
                              val2 = strlen( <ls_growth_rule>-target ) - strlen( <ls_growth_rule>-source ) ).
      rs_growth-potential = nmax(
        val1 = rs_growth-potential
        val2 = get_potential( <ls_growth_rule>-target ) - get_potential( <ls_growth_rule>-source ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_potential.
    FIND ALL OCCURRENCES OF PCRE `[A-Ze]` IN iv_molecule MATCH COUNT DATA(lv_elements).
    rv_potential = lv_elements - count( val = iv_molecule sub = `n` )
      - count( val = iv_molecule sub = `r` ) - 2 * count( val = iv_molecule sub = `Y` ).
  ENDMETHOD.

  METHOD get_lower_bound.
    DATA(lv_length_steps) = 0.
    DATA(lv_potential_steps) = 0.
    IF is_growth-length > 0.
      lv_length_steps = nmax(
        val1 = 0
        val2 = ( strlen( iv_molecule ) - 1 + is_growth-length - 1 ) DIV is_growth-length ).
    ENDIF.
    IF is_growth-potential > 0.
      lv_potential_steps = nmax(
        val1 = 0
        val2 = ( get_potential( iv_molecule ) - 1 + is_growth-potential - 1 ) DIV is_growth-potential ).
    ENDIF.
    rv_steps = nmax( val1 = lv_length_steps val2 = lv_potential_steps ).
  ENDMETHOD.

  METHOD remember_distance.
    READ TABLE ct_distances WITH TABLE KEY molecule = is_state-molecule
      ASSIGNING FIELD-SYMBOL(<ls_distance>).
    IF sy-subrc = 0.
      <ls_distance>-steps = is_state-steps.
      RETURN.
    ENDIF.
    INSERT VALUE #( molecule = is_state-molecule steps = is_state-steps ) INTO TABLE ct_distances.
  ENDMETHOD.

ENDCLASS.
