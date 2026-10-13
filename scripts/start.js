import { createInterface } from "node:readline/promises";
import { stdin, stdout } from "node:process";

const color = (code, v) => console.log(`\x1b[${code}m${v}\x1b[0m`);
const yellow = (v) => color(33, v);
const red = (v) => color(31, v);

async function run() {
    try {
        const init = await import("../output/_init.mjs");

        const Base = globalThis.abap.Classes.ZCL_A2015_BASE;
        if (!Base) throw new Error("ZCL_A2015_BASE was not found. Run npm run verify first.");

        // Prototype inheritance also discovers indirect subclasses, without a hardcoded day list.
        const names = Object.entries(globalThis.abap.Classes)
            .filter(([, Class]) => typeof Class === "function" && Class.prototype instanceof Base)
            .map(([name]) => name)
            .sort();
        if (names.length === 0) throw new Error("No subclasses of ZCL_A2015_BASE found.");
        const runAll = "ZCL_A2015_RUN_ALL";
        const hasRunAll = Boolean(globalThis.abap.Classes[runAll]);

        console.log("Available examples:");
        if (hasRunAll) console.log(`  0. ${runAll}`);
        names.forEach((name, index) => console.log(`  ${index + 1}. ${name}`));
        console.log("  -  Stop");

        let name;
        const argument = process.argv[2];
        if (argument) {
            if (argument === "-") return;
            name = /^\d+$/.test(argument)
                ? `ZCL_A2015_${argument.padStart(2, "0")}`
                : argument.toUpperCase();
            if (argument === "0" || argument.toLowerCase() === "all") name = runAll;
            if (!names.includes(name) && !(hasRunAll && name === runAll)) {
                throw new Error(`Example '${argument}' is not available.`);
            }
        } else {
            if (!stdin.isTTY) throw new Error("Select a day with npm start -- 18 (or a full class name).");
            const prompt = createInterface({ input: stdin, output: stdout });
            try {
                while (!name) {
                    const answer = (await prompt.question("Select example number (- to stop): ")).trim();
                    if (answer === "-" || answer.toLowerCase() === "q") return;
                    if (/^\d+$/.test(answer)) {
                        name = Number(answer) === 0 && hasRunAll ? runAll : names[Number(answer) - 1];
                    }
                    if (!name) console.log(`Enter ${hasRunAll ? "0 or " : ""}a number from 1 to ${names.length}, or - to stop.`);
                }
            } finally {
                prompt.close();
            }
        }

        await init.initializeABAP();

        let buf = "";
        globalThis.abap.console.add = (data) => {
            globalThis.abap.console.empty = false;
            buf += data;
            const lines = buf.split("\n");
            buf = lines.pop();
            lines.forEach(red);
        };
        const flush = () => { if (buf) red(buf); buf = ""; };

        const out = new globalThis.abap.types.ABAPObject({ qualifiedName: "IF_OO_ADT_CLASSRUN_OUT" });
        out.set({
            if_oo_adt_classrun_out$write: async ({ data }) => {
                if (typeof data.array === "function") {
                    console.table(data.array().map((row) => Object.fromEntries(
                        Object.entries(row.get()).map(([key, value]) => [key, value.get()])
                    )));
                } else {
                    yellow(data.get());
                }
                return out;
            }
        });

        console.log(`\n=== Running ${name} ===`);
        try {
            if (name === runAll) {
                // Local repository discovery and timing belong to the Node runner.
                // Each day's calculation still executes its ABAP implementation.
                const log = [];
                yellow("Each duration includes class creation, input loading, initialization and both parts.");
                for (const class_name of names) {
                    yellow(`--- ${class_name} ---`);
                    const started = performance.now();
                    let status = "OK", error = "";
                    try {
                        const instance = await new globalThis.abap.Classes[class_name]().constructor_();
                        await instance.if_oo_adt_classrun$main({ out });
                    } catch (failure) {
                        status = "ERROR";
                        error = failure?.message ?? String(failure);
                        red(`ERROR: ${error}`);
                    }
                    log.push({ class_name, elapsed_seconds: (performance.now() - started) / 1000, status, error });
                    flush();
                }
                log.sort((left, right) => right.elapsed_seconds - left.elapsed_seconds
                    || left.class_name.localeCompare(right.class_name));
                yellow("Execution summary (slowest first; elapsed_seconds is in seconds)");
                console.table(log);
            } else {
                const instance = await new globalThis.abap.Classes[name]().constructor_();
                await instance.if_oo_adt_classrun$main({ out });
            }
        } finally {
            flush();
        }
    } catch (error) {
        console.error("ABAP Runtime Error:", error);
        process.exitCode = 1;
    }
}

run();
