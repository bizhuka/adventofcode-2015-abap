CLASS ltc_calibration DEFINITION FINAL
	FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
	PRIVATE SECTION.
		DATA mo_cut TYPE REF TO zcl_a2015_base.

		METHODS setup.
		METHODS init_example IMPORTING iv_molecule TYPE string.
		METHODS hoh_has_four_results FOR TESTING.
		METHODS hohoho_has_seven_results FOR TESTING.
		METHODS ignores_surrounding_chars FOR TESTING.
		METHODS replaces_multichar_source FOR TESTING.
		METHODS includes_overlapping_matches FOR TESTING.
		METHODS deduplicates_repeated_rules FOR TESTING.
		METHODS replaces_exactly_once FOR TESTING.
		METHODS replaces_entire_molecule FOR TESTING.
		METHODS treats_sources_literally FOR TESTING.
		METHODS longer_source_has_no_match FOR TESTING.
		METHODS empty_input_has_no_results FOR TESTING.
		METHODS repeated_calls_are_stable FOR TESTING.
		METHODS reinitialization_clears_state FOR TESTING.
		METHODS init_fabrication IMPORTING iv_molecule TYPE string.
		METHODS hoh_needs_three_steps FOR TESTING.
		METHODS hohoho_needs_six_steps FOR TESTING.
		METHODS electron_needs_no_steps FOR TESTING.
		METHODS finds_global_minimum FOR TESTING.
		METHODS escapes_greedy_dead_end FOR TESTING.
		METHODS reverses_overlapping_matches FOR TESTING.
		METHODS supports_shrinking_rules FOR TESTING.
		METHODS handles_equal_length_cycles FOR TESTING.
		METHODS reports_unreachable_target FOR TESTING.
		METHODS preserves_embedded_electron FOR TESTING.
		METHODS fabrication_calls_are_stable FOR TESTING.
		METHODS result_methods_are_independent FOR TESTING.
		METHODS reinitializes_fabrication FOR TESTING.
ENDCLASS.

CLASS ltc_calibration IMPLEMENTATION.
	METHOD setup.
		mo_cut = NEW zcl_a2015_19( ).
	ENDMETHOD.

	METHOD init_example.
		mo_cut->init( VALUE #( ( `H => HO` ) ( `H => OH` ) ( `O => HH` )
													( `` ) ( iv_molecule ) ) ).
	ENDMETHOD.

	METHOD hoh_has_four_results.
		init_example( `HOH` ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `4` ).
	ENDMETHOD.

	METHOD hohoho_has_seven_results.
		init_example( `HOHOHO` ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `7` ).
	ENDMETHOD.

	METHOD ignores_surrounding_chars.
		mo_cut->init( VALUE #( ( `H => OO` ) ( `O => HH` ) ( `` ) ( `H2O` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD replaces_multichar_source.
		mo_cut->init( VALUE #( ( `He => X` ) ( `` ) ( `HeHe` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD includes_overlapping_matches.
		mo_cut->init( VALUE #( ( `HH => O` ) ( `` ) ( `HHH` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD deduplicates_repeated_rules.
		mo_cut->init( VALUE #( ( `H => HO` ) ( `H => HO` ) ( `` ) ( `HOH` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD replaces_exactly_once.
		mo_cut->init( VALUE #( ( `H => HO` ) ( `` ) ( `HH` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD replaces_entire_molecule.
		mo_cut->init( VALUE #( ( `H => OO` ) ( `` ) ( `H` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `1` ).
	ENDMETHOD.

	METHOD treats_sources_literally.
		mo_cut->init( VALUE #( ( `. => X` ) ( `` ) ( `A.A` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `1` ).
	ENDMETHOD.

	METHOD longer_source_has_no_match.
		mo_cut->init( VALUE #( ( `HH => O` ) ( `` ) ( `H` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `0` ).
	ENDMETHOD.

	METHOD empty_input_has_no_results.
		mo_cut->init( VALUE #( ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `0` ).
	ENDMETHOD.

	METHOD repeated_calls_are_stable.
		init_example( `HOH` ).
		DATA(lv_first_result) = mo_cut->get_result1( ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = lv_first_result ).
	ENDMETHOD.

	METHOD reinitialization_clears_state.
		init_example( `HOH` ).
		mo_cut->get_result1( ).
		mo_cut->init( VALUE #( ( `H => N` ) ( `` ) ( `H` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `1` ).

		mo_cut->init( VALUE #( ) ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `0` ).
	ENDMETHOD.

	METHOD init_fabrication.
		mo_cut->init( VALUE #( ( `e => H` ) ( `e => O` )
													( `H => HO` ) ( `H => OH` ) ( `O => HH` )
													( `` ) ( iv_molecule ) ) ).
	ENDMETHOD.

	METHOD hoh_needs_three_steps.
		init_fabrication( `HOH` ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `3` ).
	ENDMETHOD.

	METHOD hohoho_needs_six_steps.
		init_fabrication( `HOHOHO` ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `6` ).
	ENDMETHOD.

	METHOD electron_needs_no_steps.
		init_fabrication( `e` ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `0` ).
	ENDMETHOD.

	METHOD finds_global_minimum.
		mo_cut->init( VALUE #( ( `e => X` ) ( `X => AB` ) ( `AB => ABCDE` )
													( `e => XYZ` ) ( `XYZ => ABCDE` ) ( `` ) ( `ABCDE` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD escapes_greedy_dead_end.
		mo_cut->init( VALUE #( ( `e => BC` ) ( `BC => ABCD` )
													( `A => ABCD` ) ( `` ) ( `ABCD` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD reverses_overlapping_matches.
		mo_cut->init( VALUE #( ( `e => HO` ) ( `O => HH` ) ( `` ) ( `HHH` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD supports_shrinking_rules.
		mo_cut->init( VALUE #( ( `e => ABC` ) ( `ABC => H` ) ( `` ) ( `H` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD handles_equal_length_cycles.
		mo_cut->init( VALUE #( ( `e => H` ) ( `H => O` ) ( `O => H` ) ( `` ) ( `O` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `2` ).
	ENDMETHOD.

	METHOD reports_unreachable_target.
		mo_cut->init( VALUE #( ( `H => O` ) ( `O => H` ) ( `` ) ( `H` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `No solution` ) ##NO_TEXT.
	ENDMETHOD.

	METHOD preserves_embedded_electron.
		mo_cut->init( VALUE #( ( `e => He` ) ( `` ) ( `He` ) ) ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `1` ).
	ENDMETHOD.

	METHOD fabrication_calls_are_stable.
		init_fabrication( `HOH` ).
		DATA(lv_first_result) = mo_cut->get_result2( ).

		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = lv_first_result ).
	ENDMETHOD.

	METHOD result_methods_are_independent.
		init_fabrication( `HOH` ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `3` ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result1( )
																			 exp = `4` ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `3` ).
	ENDMETHOD.

	METHOD reinitializes_fabrication.
		init_fabrication( `HOH` ).
		mo_cut->get_result2( ).
		mo_cut->init( VALUE #( ( `e => H` ) ( `` ) ( `H` ) ) ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `1` ).

		mo_cut->init( VALUE #( ) ).
		cl_abap_unit_assert=>assert_equals( act = mo_cut->get_result2( )
																			 exp = `No solution` ) ##NO_TEXT.
	ENDMETHOD.
ENDCLASS.
