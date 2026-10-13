import test from "node:test";
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
const init = await import("../output/_init.mjs");
await init.initializeABAP();
const Digest = abap.Classes.CL_ABAP_MESSAGE_DIGEST;

async function hash(data, algorithm, length) {
  const outputs = {
    ef_hashstring: new abap.types.String(),
    ef_hashxstring: new abap.types.XString(),
    ef_hashb64string: new abap.types.String(),
    ef_hashx: new abap.types.Hex({length:64})
  };
  const input = {if_data:new abap.types.String().set(data), ...outputs};
  if (algorithm !== undefined) input.if_algorithm = new abap.types.String().set(algorithm);
  if (length !== undefined) input.if_length = new abap.types.Integer().set(length);
  await Digest.calculate_hash_for_char(input);
  return Object.fromEntries(Object.entries(outputs).map(([key,value]) => [key,value.get()]));
}

test("character hashing returns complete digests and every export for supported algorithms", async () => {
  for (const algorithm of ["MD5","SHA1","SHA224","SHA256","SHA384","SHA512"]) {
    for (const data of ["","abc","é漢字😀","x".repeat(55),"x".repeat(56),"x".repeat(1024)]) {
      const buffer = createHash(algorithm.toLowerCase()).update(data,"utf8").digest();
      const hex = buffer.toString("hex").toUpperCase();
      const result = await hash(data,algorithm);
      assert.equal(result.ef_hashstring,hex);
      assert.equal(result.ef_hashxstring,hex);
      assert.equal(result.ef_hashb64string,buffer.toString("base64"));
      assert.equal(result.ef_hashx,hex.padEnd(128,"0"));
    }
  }
});

test("default algorithm, aliases and character length retain existing behavior", async () => {
  const expected = createHash("sha1").update("abc").digest("hex").toUpperCase();
  assert.equal((await hash("abc")).ef_hashstring,expected);
  assert.equal((await hash("abc"," sHa-1 ")).ef_hashstring,expected);
  for (const [data,length,sliced] of [["é汉字",2,"é汉"],["abc",0,"abc"],["abc",-1,"abc"],["abc",3,"abc"]]) {
    const hex = createHash("md5").update(sliced).digest("hex").toUpperCase();
    assert.equal((await hash(data,"MD5",length)).ef_hashstring,hex);
  }
});

test("unknown algorithms and out-of-range character lengths still fail", async () => {
  await assert.rejects(hash("abc","ROT13"),error => error.constructor.INTERNAL_NAME === "CX_ABAP_MESSAGE_DIGEST");
  await assert.rejects(hash("abc","MD5",4));
});

test("optimized character hashing agrees with the independent raw path for UTF-8", async () => {
  for (const data of ["a","é漢字😀","x".repeat(100)]) {
    const raw = new abap.types.XString().set(Buffer.from(data,"utf8").toString("hex").toUpperCase());
    const actual = new abap.types.XString();
    await Digest.calculate_hash_for_raw({if_algorithm:new abap.types.String().set("MD5"),if_data:raw,ef_hashxstring:actual});
    assert.equal((await hash(data,"MD5")).ef_hashxstring,actual.get());
  }
});
