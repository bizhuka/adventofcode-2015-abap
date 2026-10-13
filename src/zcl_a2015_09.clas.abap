CLASS zcl_a2015_09 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_edge,
        from_loc TYPE string,
        to_loc   TYPE string,
        dist     TYPE i,
      END OF ty_edge,

      BEGIN OF ty_state,
        counter TYPE i, " counter for each position (size N).
        index   TYPE i,
      END OF ty_state.

    DATA:
      mt_edges     TYPE STANDARD TABLE OF ty_edge WITH EMPTY KEY
                                                  WITH UNIQUE SORTED KEY direct   COMPONENTS from_loc to_loc
                                                  WITH UNIQUE SORTED KEY opposite COMPONENTS to_loc from_loc,
      mt_locations TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
      mt_distances TYPE STANDARD TABLE OF i WITH EMPTY KEY,
      mt_state     TYPE STANDARD TABLE OF ty_state WITH EMPTY KEY.

    METHODS:
      calculate_route_dist
        RETURNING VALUE(rv_dist) TYPE i,
      solve
        IMPORTING iv_type          TYPE string
        RETURNING VALUE(rv_result) TYPE ty_big_int.
ENDCLASS.

CLASS zcl_a2015_09 IMPLEMENTATION.

  METHOD init.
    CLEAR: mt_edges, mt_locations.
    LOOP AT it_input ASSIGNING FIELD-SYMBOL(<line>) WHERE table_line CS '='.
      SPLIT <line> AT ` = ` INTO DATA(lv_path) DATA(lv_dist_str).
      SPLIT lv_path AT ` to ` INTO DATA(lv_from_raw) DATA(lv_to_raw).

      CONDENSE lv_from_raw.
      CONDENSE lv_to_raw.
      CONDENSE lv_dist_str.

      INSERT VALUE #( from_loc = lv_from_raw to_loc = lv_to_raw dist = lv_dist_str ) INTO TABLE mt_edges[].

      INSERT lv_from_raw INTO TABLE mt_locations[].
      INSERT lv_to_raw   INTO TABLE mt_locations[].
    ENDLOOP.
  ENDMETHOD.

  METHOD solve.
    DATA(lv_locations_count) = lines( mt_locations ).
    IF lv_locations_count < 2.
      rv_result = 0.
      RETURN.
    ENDIF.

    " Resolve names and directions once, outside the permutation hot loop.
    CLEAR mt_distances.
    LOOP AT mt_locations INTO DATA(lv_from).
      LOOP AT mt_locations INTO DATA(lv_to).
        ASSIGN mt_edges[ from_loc = lv_from to_loc = lv_to ] TO FIELD-SYMBOL(<ls_edge>).
        IF sy-subrc <> 0.
          ASSIGN mt_edges[ from_loc = lv_to to_loc = lv_from ] TO <ls_edge>.
        ENDIF.
        DATA(lv_edge_distance) = COND i( WHEN sy-subrc = 0 THEN <ls_edge>-dist ELSE -1 ).
        APPEND lv_edge_distance TO mt_distances.
      ENDLOOP.
    ENDLOOP.

    " Heap's Algorithm - Initialization
    " We map 0-based algorithm logic to 1-based internal tables
    mt_state = VALUE #( FOR i = 1 THEN i + 1 UNTIL i > lv_locations_count (
      counter = 0
      index   = i
    ) ).

    " Initialize best result
    " For MIN: High value. For MAX: 0.
    DATA(lv_best) = COND ty_big_int( WHEN iv_type = 'MIN' THEN cl_abap_math=>max_int4
                                                          ELSE 0 ).

    " Evaluate Initial Permutation
    DATA(lv_dist)  = calculate_route_dist( ).
    IF lv_dist > 0.
      lv_best = lv_dist.
    ENDIF.

    DATA(lv_index) = 0.
    WHILE lv_index < lv_locations_count.
      ASSIGN mt_state[ lv_index + 1 ] TO FIELD-SYMBOL(<lfs_next_state>).  " Corresponds to 'i' in algorithm

      IF <lfs_next_state>-counter >= lv_index.
        <lfs_next_state>-counter = 0.
        lv_index += 1.
        CONTINUE.
      ENDIF.

      " Determine swap index based on parity of lv_index (i)
      DATA(lv_swap_idx) = COND i( WHEN lv_index MOD 2 = 0
                                  THEN 1
                                  ELSE <lfs_next_state>-counter + 1 ).

      " SWAP Logic: Swap element at lv_swap_idx with element at lv_index + 1 (i)
      ASSIGN mt_state[ lv_swap_idx ] TO FIELD-SYMBOL(<lfs_swap_state>).

      DATA(lv_temp) = <lfs_swap_state>-index.
      <lfs_swap_state>-index = <lfs_next_state>-index.
      <lfs_next_state>-index = lv_temp.

      " Build route and calculate distance
      lv_dist = calculate_route_dist( ).
      IF lv_dist > 0.
        lv_best = SWITCH #( iv_type
          WHEN 'MIN' THEN COND #( WHEN lv_dist < lv_best THEN lv_dist ELSE lv_best )
          WHEN 'MAX' THEN COND #( WHEN lv_dist > lv_best THEN lv_dist ELSE lv_best ) ).
      ENDIF.

      <lfs_next_state>-counter += 1.
      lv_index = 0.
    ENDWHILE.

    rv_result = lv_best.
  ENDMETHOD.

  METHOD get_result1.
    rv_result = solve( 'MIN' ).
  ENDMETHOD.

  METHOD get_result2.
    rv_result = solve( 'MAX' ).
  ENDMETHOD.

  METHOD calculate_route_dist.
    rv_dist = 0.

    DATA(lv_count) = lines( mt_state ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    DO lv_count - 1 TIMES.
      DATA(lv_curr) = mt_state[ sy-index ]-index.
      DATA(lv_next) = mt_state[ sy-index + 1 ]-index.
      DATA(lv_distance) = mt_distances[ ( lv_curr - 1 ) * lv_count + lv_next ].
      IF lv_distance < 0.
        rv_dist = -1.
        RETURN.
      ENDIF.

      rv_dist += lv_distance.
    ENDDO.
  ENDMETHOD.

ENDCLASS.

