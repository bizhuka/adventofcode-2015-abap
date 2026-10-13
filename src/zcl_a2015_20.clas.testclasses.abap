CLASS ltc_presents DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_a2015_20.
    METHODS setup.
    METHODS examples FOR TESTING.
    METHODS exact_thresholds FOR TESTING.
    METHODS limited_delivery FOR TESTING.
    METHODS fiftieth_visit FOR TESTING.
    METHODS repeat_and_reinitialize FOR TESTING.
    METHODS blank_and_zero FOR TESTING.
    METHODS line_endings FOR TESTING.
    METHODS puzzle_input FOR TESTING.
ENDCLASS.

CLASS ltc_presents IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD examples.
    TYPES: BEGIN OF lty_example,
             target TYPE i,
             house TYPE i,
           END OF lty_example.
    TYPES ltt_examples TYPE STANDARD TABLE OF lty_example WITH EMPTY KEY.
    DATA(lt_examples) = VALUE ltt_examples(
      ( target = 10 house = 1 ) ( target = 30 house = 2 )
      ( target = 40 house = 3 ) ( target = 70 house = 4 )
      ( target = 60 house = 4 ) ( target = 120 house = 6 )
      ( target = 80 house = 6 ) ( target = 150 house = 8 )
      ( target = 130 house = 8 ) ).
    LOOP AT lt_examples ASSIGNING FIELD-SYMBOL(<ls_example>).
      mo_cut->init( VALUE #( ( |{ <ls_example>-target }| ) ) ).
      cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = |{ <ls_example>-house }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD exact_thresholds.
    mo_cut->init( VALUE #( ( `10` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    mo_cut->init( VALUE #( ( `11` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
    mo_cut->init( VALUE #( ( `151` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `10` ).
  ENDMETHOD.

  METHOD limited_delivery.
    " Elf 1 no longer visits house 60, so it misses 1848 and the first match is 72.
    mo_cut->init( VALUE #( ( `1848` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `72` ).
  ENDMETHOD.

  METHOD fiftieth_visit.
    " House 300 includes elf 6's 50th delivery; a 49-visit cap would miss this threshold.
    mo_cut->init( VALUE #( ( `9318` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `300` ).
  ENDMETHOD.

  METHOD repeat_and_reinitialize.
    mo_cut->init( VALUE #( ( `150` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `8` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `8` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `8` ).
    mo_cut->init( VALUE #( ( `11` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `2` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
  ENDMETHOD.

  METHOD blank_and_zero.
    mo_cut->init( VALUE #( ( `` ) ( `  70  ` ) ( `` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    mo_cut->init( VALUE #( ( `0` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `1` ).
    mo_cut->init( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `1` ).
  ENDMETHOD.

  METHOD puzzle_input.
    mo_cut->init( VALUE #( ( `34000000` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `786240` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `831600` ).
  ENDMETHOD.

  METHOD line_endings.
    mo_cut->init( VALUE #( ( |{ cl_abap_char_utilities=>newline }70{ cl_abap_char_utilities=>newline }| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `4` ).
    mo_cut->init( VALUE #( ( |150{ cl_abap_char_utilities=>cr_lf }| ) ) ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( ) exp = `8` ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( ) exp = `8` ).
  ENDMETHOD.
ENDCLASS.
