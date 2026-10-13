import { rm } from "node:fs/promises";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import "./patch-digest.mjs";

const command = fileURLToPath(new URL("../node_modules/@abaplint/transpiler-cli/abap_transpile", import.meta.url));

await rm(new URL("../output/", import.meta.url), { recursive: true, force: true });

const child = spawn(process.execPath, [command, "abap_transpile.json"], {
    stdio: "inherit",
});

await new Promise((resolve, reject) => {
    child.on("error", reject);
    child.on("exit", async (code) => {
        if (code === 0) {
            try {
                resolve();
            } catch (err) {
                reject(err);
            }
            return;
        }

        reject(new Error(`ABAP transpilation exited with code ${code}`));
    });
});
