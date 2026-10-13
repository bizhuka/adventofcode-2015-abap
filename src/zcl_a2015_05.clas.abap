CLASS zcl_a2015_05 DEFINITION INHERITING FROM zcl_a2015_base PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      init        REDEFINITION,
      get_result1 REDEFINITION,
      get_result2 REDEFINITION.
    DATA:
      mt_input  TYPE string_table.
ENDCLASS.


CLASS zcl_a2015_05 IMPLEMENTATION.
  METHOD init.
    mt_input[] = it_input[].
  ENDMETHOD.

  METHOD get_result1.
    LOOP AT mt_input INTO DATA(lv_input).
      " It does not contain the strings ab, cd, pq, or xy, even if they are part of one of the other requirements
      CHECK lv_input NS 'ab' AND
            lv_input NS 'cd' AND
            lv_input NS 'pq' AND
            lv_input NS 'xy'.
      " It contains at least three vowels (aeiou only), like aei, xazegov, or aeiouaeiouaeiou
      CHECK count_any_of( val = lv_input
                          sub = 'aeiou' ) >= 3.
      " It contains at least one letter that appears twice in a row,
      " like xx, abcdde (dd), or aabbccdd (aa, bb, cc, or dd)
      CHECK find( val  = lv_input
                  pcre = '(.)\1' ) >= 0.

      rv_result += 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result2.
    LOOP AT mt_input INTO DATA(lv_input).
      " It contains a pair of any two letters that appears at least twice in the string without overlapping,
      " like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps)
      CHECK find( val  = lv_input
                  pcre = '([a-zA-Z]{2}).*\1' ) >= 0.

      " It contains at least one letter which repeats with exactly one letter between them,
      " like xyx, abcdefeghi (efe), or even aaa
      CHECK find( val  = lv_input
                  pcre = '([a-zA-Z])[a-zA-Z]\1' ) >= 0.

      rv_result += 1.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
