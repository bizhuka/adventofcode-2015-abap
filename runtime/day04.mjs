import { createHash } from "node:crypto";

// One-block MD5 compression; only rounds 1-61 affect the first digest word.
// Mining needs its first 20/24 bits, so the final three rounds are unnecessary.
export function md5FirstWord(words) {
    const w0 = words[0], w1 = words[1], w2 = words[2], w3 = words[3], w4 = words[4], w5 = words[5], w6 = words[6], w7 = words[7], w8 = words[8], w9 = words[9], w10 = words[10], w11 = words[11], w12 = words[12], w13 = words[13], w14 = words[14], w15 = words[15];
    let a = 0x67452301, b = -0x10325477, c = -0x67452302, d = 0x10325476, t;
    t = (a + ((b & c) | (~b & d)) + w0 + (-680876936)) | 0; a = (((t << 7) | (t >>> 25)) + b) | 0;
    t = (d + ((a & b) | (~a & c)) + w1 + (-389564586)) | 0; d = (((t << 12) | (t >>> 20)) + a) | 0;
    t = (c + ((d & a) | (~d & b)) + w2 + (606105819)) | 0; c = (((t << 17) | (t >>> 15)) + d) | 0;
    t = (b + ((c & d) | (~c & a)) + w3 + (-1044525330)) | 0; b = (((t << 22) | (t >>> 10)) + c) | 0;
    t = (a + ((b & c) | (~b & d)) + w4 + (-176418897)) | 0; a = (((t << 7) | (t >>> 25)) + b) | 0;
    t = (d + ((a & b) | (~a & c)) + w5 + (1200080426)) | 0; d = (((t << 12) | (t >>> 20)) + a) | 0;
    t = (c + ((d & a) | (~d & b)) + w6 + (-1473231341)) | 0; c = (((t << 17) | (t >>> 15)) + d) | 0;
    t = (b + ((c & d) | (~c & a)) + w7 + (-45705983)) | 0; b = (((t << 22) | (t >>> 10)) + c) | 0;
    t = (a + ((b & c) | (~b & d)) + w8 + (1770035416)) | 0; a = (((t << 7) | (t >>> 25)) + b) | 0;
    t = (d + ((a & b) | (~a & c)) + w9 + (-1958414417)) | 0; d = (((t << 12) | (t >>> 20)) + a) | 0;
    t = (c + ((d & a) | (~d & b)) + w10 + (-42063)) | 0; c = (((t << 17) | (t >>> 15)) + d) | 0;
    t = (b + ((c & d) | (~c & a)) + w11 + (-1990404162)) | 0; b = (((t << 22) | (t >>> 10)) + c) | 0;
    t = (a + ((b & c) | (~b & d)) + w12 + (1804603682)) | 0; a = (((t << 7) | (t >>> 25)) + b) | 0;
    t = (d + ((a & b) | (~a & c)) + w13 + (-40341101)) | 0; d = (((t << 12) | (t >>> 20)) + a) | 0;
    t = (c + ((d & a) | (~d & b)) + w14 + (-1502002290)) | 0; c = (((t << 17) | (t >>> 15)) + d) | 0;
    t = (b + ((c & d) | (~c & a)) + w15 + (1236535329)) | 0; b = (((t << 22) | (t >>> 10)) + c) | 0;
    t = (a + ((b & d) | (c & ~d)) + w1 + (-165796510)) | 0; a = (((t << 5) | (t >>> 27)) + b) | 0;
    t = (d + ((a & c) | (b & ~c)) + w6 + (-1069501632)) | 0; d = (((t << 9) | (t >>> 23)) + a) | 0;
    t = (c + ((d & b) | (a & ~b)) + w11 + (643717713)) | 0; c = (((t << 14) | (t >>> 18)) + d) | 0;
    t = (b + ((c & a) | (d & ~a)) + w0 + (-373897302)) | 0; b = (((t << 20) | (t >>> 12)) + c) | 0;
    t = (a + ((b & d) | (c & ~d)) + w5 + (-701558691)) | 0; a = (((t << 5) | (t >>> 27)) + b) | 0;
    t = (d + ((a & c) | (b & ~c)) + w10 + (38016083)) | 0; d = (((t << 9) | (t >>> 23)) + a) | 0;
    t = (c + ((d & b) | (a & ~b)) + w15 + (-660478335)) | 0; c = (((t << 14) | (t >>> 18)) + d) | 0;
    t = (b + ((c & a) | (d & ~a)) + w4 + (-405537848)) | 0; b = (((t << 20) | (t >>> 12)) + c) | 0;
    t = (a + ((b & d) | (c & ~d)) + w9 + (568446438)) | 0; a = (((t << 5) | (t >>> 27)) + b) | 0;
    t = (d + ((a & c) | (b & ~c)) + w14 + (-1019803690)) | 0; d = (((t << 9) | (t >>> 23)) + a) | 0;
    t = (c + ((d & b) | (a & ~b)) + w3 + (-187363961)) | 0; c = (((t << 14) | (t >>> 18)) + d) | 0;
    t = (b + ((c & a) | (d & ~a)) + w8 + (1163531501)) | 0; b = (((t << 20) | (t >>> 12)) + c) | 0;
    t = (a + ((b & d) | (c & ~d)) + w13 + (-1444681467)) | 0; a = (((t << 5) | (t >>> 27)) + b) | 0;
    t = (d + ((a & c) | (b & ~c)) + w2 + (-51403784)) | 0; d = (((t << 9) | (t >>> 23)) + a) | 0;
    t = (c + ((d & b) | (a & ~b)) + w7 + (1735328473)) | 0; c = (((t << 14) | (t >>> 18)) + d) | 0;
    t = (b + ((c & a) | (d & ~a)) + w12 + (-1926607734)) | 0; b = (((t << 20) | (t >>> 12)) + c) | 0;
    t = (a + (b ^ c ^ d) + w5 + (-378558)) | 0; a = (((t << 4) | (t >>> 28)) + b) | 0;
    t = (d + (a ^ b ^ c) + w8 + (-2022574463)) | 0; d = (((t << 11) | (t >>> 21)) + a) | 0;
    t = (c + (d ^ a ^ b) + w11 + (1839030562)) | 0; c = (((t << 16) | (t >>> 16)) + d) | 0;
    t = (b + (c ^ d ^ a) + w14 + (-35309556)) | 0; b = (((t << 23) | (t >>> 9)) + c) | 0;
    t = (a + (b ^ c ^ d) + w1 + (-1530992060)) | 0; a = (((t << 4) | (t >>> 28)) + b) | 0;
    t = (d + (a ^ b ^ c) + w4 + (1272893353)) | 0; d = (((t << 11) | (t >>> 21)) + a) | 0;
    t = (c + (d ^ a ^ b) + w7 + (-155497632)) | 0; c = (((t << 16) | (t >>> 16)) + d) | 0;
    t = (b + (c ^ d ^ a) + w10 + (-1094730640)) | 0; b = (((t << 23) | (t >>> 9)) + c) | 0;
    t = (a + (b ^ c ^ d) + w13 + (681279174)) | 0; a = (((t << 4) | (t >>> 28)) + b) | 0;
    t = (d + (a ^ b ^ c) + w0 + (-358537222)) | 0; d = (((t << 11) | (t >>> 21)) + a) | 0;
    t = (c + (d ^ a ^ b) + w3 + (-722521979)) | 0; c = (((t << 16) | (t >>> 16)) + d) | 0;
    t = (b + (c ^ d ^ a) + w6 + (76029189)) | 0; b = (((t << 23) | (t >>> 9)) + c) | 0;
    t = (a + (b ^ c ^ d) + w9 + (-640364487)) | 0; a = (((t << 4) | (t >>> 28)) + b) | 0;
    t = (d + (a ^ b ^ c) + w12 + (-421815835)) | 0; d = (((t << 11) | (t >>> 21)) + a) | 0;
    t = (c + (d ^ a ^ b) + w15 + (530742520)) | 0; c = (((t << 16) | (t >>> 16)) + d) | 0;
    t = (b + (c ^ d ^ a) + w2 + (-995338651)) | 0; b = (((t << 23) | (t >>> 9)) + c) | 0;
    t = (a + (c ^ (b | ~d)) + w0 + (-198630844)) | 0; a = (((t << 6) | (t >>> 26)) + b) | 0;
    t = (d + (b ^ (a | ~c)) + w7 + (1126891415)) | 0; d = (((t << 10) | (t >>> 22)) + a) | 0;
    t = (c + (a ^ (d | ~b)) + w14 + (-1416354905)) | 0; c = (((t << 15) | (t >>> 17)) + d) | 0;
    t = (b + (d ^ (c | ~a)) + w5 + (-57434055)) | 0; b = (((t << 21) | (t >>> 11)) + c) | 0;
    t = (a + (c ^ (b | ~d)) + w12 + (1700485571)) | 0; a = (((t << 6) | (t >>> 26)) + b) | 0;
    t = (d + (b ^ (a | ~c)) + w3 + (-1894986606)) | 0; d = (((t << 10) | (t >>> 22)) + a) | 0;
    t = (c + (a ^ (d | ~b)) + w10 + (-1051523)) | 0; c = (((t << 15) | (t >>> 17)) + d) | 0;
    t = (b + (d ^ (c | ~a)) + w1 + (-2054922799)) | 0; b = (((t << 21) | (t >>> 11)) + c) | 0;
    t = (a + (c ^ (b | ~d)) + w8 + (1873313359)) | 0; a = (((t << 6) | (t >>> 26)) + b) | 0;
    t = (d + (b ^ (a | ~c)) + w15 + (-30611744)) | 0; d = (((t << 10) | (t >>> 22)) + a) | 0;
    t = (c + (a ^ (d | ~b)) + w6 + (-1560198380)) | 0; c = (((t << 15) | (t >>> 17)) + d) | 0;
    t = (b + (d ^ (c | ~a)) + w13 + (1309151649)) | 0; b = (((t << 21) | (t >>> 11)) + c) | 0;
    t = (a + (c ^ (b | ~d)) + w4 + (-145523070)) | 0; a = (((t << 6) | (t >>> 26)) + b) | 0;
    return (a + 0x67452301) >>> 0;
}

function mineWithCrypto(prefix, zeros, candidate) {
    const mask = zeros === 5 ? 0xF0 : 0xFF;
    while (true) {
        const hash = createHash("md5").update(prefix + candidate).digest();
        if (hash[0] === 0 && hash[1] === 0 && (hash[2] & mask) === 0) return candidate;
        candidate++;
    }
}

export function mineMd5(prefix, zeros, previous) {
    const key = Buffer.from(prefix, "utf8");
    // Longer inputs require multiple blocks; retain Node's general MD5 implementation.
    if (key.length >= 55 || new Uint8Array(new Uint16Array([1]).buffer)[0] !== 1) {
        return mineWithCrypto(prefix, zeros, previous + 1);
    }
    const bytes = new Uint8Array(64);
    const words = new Int32Array(bytes.buffer);
    bytes.set(key);
    const mask = zeros === 5 ? 0x00F0FFFF : 0x00FFFFFF;
    let candidate = previous;
    while (true) {
        candidate++;
        const suffix = String(candidate);
        const length = key.length + suffix.length;
        if (length > 55) return mineWithCrypto(prefix, zeros, candidate);
        for (let index = 0; index < suffix.length; index++) bytes[key.length + index] = suffix.charCodeAt(index);
        bytes[length] = 0x80;
        words[14] = length * 8;
        if ((md5FirstWord(words) & mask) === 0) return candidate;
    }
}
