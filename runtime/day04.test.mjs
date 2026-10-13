import test from "node:test";
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { md5FirstWord, mineMd5 } from "./day04.mjs";

test("one-block MD5 matches Node for padding boundaries and seeded UTF-8 messages", () => {
    const messages = ["", "a", "abc", "x".repeat(54), "x".repeat(55), "\u00e9".repeat(27) + "1"];
    let seed = 123456;
    const alphabet = "0123456789abcdefXYZ\u00e9";
    for (let sample = 0; sample < 500; sample++) {
        let message = "";
        const length = sample % 40;
        for (let index = 0; index < length; index++) {
            seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
            message += alphabet[seed % alphabet.length];
        }
        messages.push(message);
    }
    for (const message of messages) {
        const input = Buffer.from(message, "utf8");
        const bytes = new Uint8Array(64);
        bytes.set(input);
        bytes[input.length] = 0x80;
        const words = new Int32Array(bytes.buffer);
        words[14] = input.length * 8;
        assert.equal(md5FirstWord(words), createHash("md5").update(message).digest().readUInt32LE(0), message);
    }
});

test("mining includes the first candidate and handles decimal length changes", () => {
    assert.equal(mineMd5("abcdef", 5, 99), 609043);
    assert.equal(mineMd5("abcdef", 6, 6742838), 6742839);
    assert.equal(mineMd5("abap-test-14755889", 6, 0), 1);
});

test("mining falls back to Node when a changing suffix requires a second block", () => {
    assert.equal(mineMd5("x".repeat(54), 5, 0), 324703);
});

test("long UTF-8 prefixes use byte length when selecting the fallback", () => {
    assert.equal(mineMd5("\u00e9".repeat(28), 5, 642373), 642374);
});
