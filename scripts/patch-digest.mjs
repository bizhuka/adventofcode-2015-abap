import { readFile, writeFile } from "node:fs/promises";

// Keep this focused open-abap-core change across dependency reinstalls.
const path = new URL("../node_modules/open-abap-core/src/abap/hash/cl_abap_message_digest.clas.abap", import.meta.url);
const original = `  METHOD calculate_hash_for_char.
    DATA lv_data TYPE string.

    IF if_length > 0.
      lv_data = if_data(if_length).
    ELSE.
      lv_data = if_data.
    ENDIF.

    calculate_hash_for_raw(
      EXPORTING
        if_algorithm     = if_algorithm
        if_data          = string_to_xstring( lv_data )
      IMPORTING
        ef_hashstring    = ef_hashstring
        ef_hashxstring   = ef_hashxstring
        ef_hashb64string = ef_hashb64string
        ef_hashx         = ef_hashx ).
  ENDMETHOD.`;
const replacement = `  METHOD calculate_hash_for_char.
    DATA lv_data TYPE string.
    DATA ls_algorithm TYPE ty_algorithm.

    IF if_length > 0.
      lv_data = if_data(if_length).
    ELSE.
      lv_data = if_data.
    ENDIF.
    ls_algorithm = resolve( if_algorithm ).

    " Hash UTF-8 directly; avoid converting text to hex and back for every call.
    WRITE '@KERNEL const crypto = abap.Classes.CL_ABAP_MESSAGE_DIGEST.crypto ??= await import("node:crypto");'.
    WRITE '@KERNEL const digest = crypto.createHash(ls_algorithm.get().node.get()).update(lv_data.get(), "utf8").digest();'.
    WRITE '@KERNEL const hex = digest.toString("hex").toUpperCase();'.
    WRITE '@KERNEL ef_hashstring.set(hex); ef_hashxstring.set(hex); ef_hashx.set(hex);'.
    WRITE '@KERNEL ef_hashb64string.set(digest.toString("base64"));'.
  ENDMETHOD.`;
const source = await readFile(path, "utf8");
const method = source.match(/  METHOD calculate_hash_for_char\.[\s\S]*?  ENDMETHOD\./)?.[0];
const normalized = method?.replace(/\r\n/g, "\n");
if (normalized !== original && normalized !== replacement) {
  throw new Error("open-abap-core calculate_hash_for_char changed; review the digest patch before applying it.");
}
if (normalized !== replacement) await writeFile(path, source.replace(method, replacement));
