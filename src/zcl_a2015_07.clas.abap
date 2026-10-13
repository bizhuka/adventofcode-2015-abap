CLASS zcl_a2015_07 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.

  PRIVATE SECTION.
    TYPES: ty_value TYPE x LENGTH 2,
           BEGIN OF ENUM c_operator,
             o_assign,
             o_and,
             o_or,
             o_not,
             o_lshift,
             o_rshift,
           END OF ENUM c_operator,

           BEGIN OF ts_tree,
             name         TYPE string,
             operator     TYPE c_operator,
             operand_1    TYPE string,
             operand_2    TYPE string,
             cached_value TYPE REF TO i,
           END OF ts_tree,
           tt_tree TYPE SORTED TABLE OF ts_tree WITH UNIQUE KEY name.

    METHODS:
      _add_tree        IMPORTING iv_input         TYPE string,
      _get_value       IMPORTING ir_tree          TYPE REF TO ts_tree
                       RETURNING VALUE(rv_result) TYPE ty_value,
      _resolve_operand IMPORTING iv_operand       TYPE string RETURNING VALUE(rv_value) TYPE ty_value.

    DATA:
      mt_input    TYPE string_table,
      mt_all_tree TYPE tt_tree.
ENDCLASS.



CLASS zcl_a2015_07 IMPLEMENTATION.
  METHOD init.
    mt_input[] = it_input[].
  ENDMETHOD.

  METHOD _add_tree.
    FIND REGEX `^(NOT )?([a-z0-9]+)(?: (AND|OR|[LR]SHIFT) ([a-z0-9]+))? -> ([a-z]+)$` IN iv_input
     SUBMATCHES DATA(lv_unary_op)
                DATA(lv_op1)
                DATA(lv_binary_op)
                DATA(lv_op2)
                DATA(lv_dest).
    ASSERT sy-subrc IS INITIAL.

    DATA(ls_tree) = VALUE ts_tree(
      name      = lv_dest
      operand_1 = lv_op1
      operand_2 = lv_op2 ).

    lv_unary_op = condense( lv_unary_op ).
    ls_tree-operator = COND #(
                       WHEN lv_unary_op  = 'NOT'    THEN o_not
                       WHEN lv_binary_op = 'AND'    THEN o_and
                       WHEN lv_binary_op = 'OR'     THEN o_or
                       WHEN lv_binary_op = 'LSHIFT' THEN o_lshift
                       WHEN lv_binary_op = 'RSHIFT' THEN o_rshift
                       ELSE                              o_assign ).

    INSERT ls_tree INTO TABLE mt_all_tree.
  ENDMETHOD.

  METHOD _get_value.
    IF ir_tree->cached_value IS NOT INITIAL.
      rv_result = ir_tree->cached_value->*.
      RETURN.
    ENDIF.

    DATA(lv_val1) = _resolve_operand( ir_tree->operand_1 ).
    DATA(lv_val2) = COND #( WHEN ir_tree->operand_2 IS NOT INITIAL
                            THEN _resolve_operand( ir_tree->operand_2 ) ).
    CASE ir_tree->operator.
      WHEN o_assign.
      WHEN o_not.    lv_val1 =         BIT-NOT lv_val1.
      WHEN o_and.    lv_val1 = lv_val1 BIT-AND lv_val2.
      WHEN o_or.     lv_val1 = lv_val1 BIT-OR  lv_val2.

      WHEN o_lshift.
        " Left Shift = Multiply by 2^N.          SHIFT lv_val1 BY CONV i( lv_val2 )  PLACES LEFT IN BYTE MODE.  " CIRCULAR
        lv_val1          = CONV i( lv_val1 ) *   ipow( base = 2 exp = lv_val2 ).

      WHEN o_rshift.
        " Right Shift = Integer Division by 2^N.  SHIFT lv_val1 BY CONV i( lv_val2 ) PLACES RIGHT IN BYTE MODE. " CIRCULAR
        lv_val1          = CONV i( lv_val1 ) DIV ipow( base = 2 exp = lv_val2 ).
    ENDCASE.

    " Enforce 16-bit unsigned limit (0-65535)
    "lv_val1 = lv_val1 BIT-AND CONV ty_value( 'FFFF' ).

    CREATE DATA ir_tree->cached_value.
    ir_tree->cached_value->* = lv_val1.
    rv_result = ir_tree->cached_value->*.
  ENDMETHOD.

  METHOD _resolve_operand.
    IF iv_operand CO '0123456789'.
      rv_value = CONV i( iv_operand ).
      RETURN.
    ENDIF.

    ASSIGN mt_all_tree[ name = iv_operand ] TO FIELD-SYMBOL(<ls_tree>).
    ASSERT sy-subrc = 0.

    rv_value = _get_value( REF #( <ls_tree> ) ).
  ENDMETHOD.

  METHOD get_result1.
    LOOP AT mt_input INTO DATA(lv_input).
      _add_tree( lv_input ).
    ENDLOOP.

    rv_result = CONV i( _get_value( REF #( mt_all_tree[ name = 'a' ] ) ) ).
  ENDMETHOD.

  METHOD get_result2.
    " calculate the value of wire 'a' from Part 1
    " Convert the string result to an integer to remove the trailing sign blank.
    " Otherwise the override contains two spaces before '-> b' and fails _add_tree's regex.
    DATA(lv_part1_a) = CONV i( get_result1( ) ).

    " reset the circuit for Part 2
    CLEAR mt_all_tree[].

    " reload wires, but OVERRIDE wire 'b' with Part 1 result
    LOOP AT mt_input INTO DATA(lv_input).

      " check if this instruction assigns to wire 'b' (ends with "-> b")
      IF find( val   = lv_input
               regex = '-> b$' ) >= 0.
        "override: Replace instruction with specific value assignment
        lv_input = |{ lv_part1_a } -> b|.
      ENDIF.

      _add_tree( lv_input ).
    ENDLOOP.

    " calculate the new value of wire 'a'
    rv_result = CONV i( _get_value( REF #( mt_all_tree[ name = 'a' ] ) ) ).
  ENDMETHOD.
ENDCLASS.
