import { readdir, readFile } from "node:fs/promises";
import { MemoryFile, Registry } from "@abaplint/core";

const outputDirectory = new URL("../output/project/", import.meta.url);
let outputBuffer = "";

const red = (value) => `\x1b[31m${value}\x1b[0m`;

function textOf(value) {
    if (typeof value === "string") {
        return value;
    }
    if (value && typeof value.get === "function") {
        return value.get();
    }
    return String(value);
}

function flushOutput() {
    if (outputBuffer.length > 0) {
        console.log(`  ${outputBuffer}`);
        outputBuffer = "";
    }
}

function errorFieldText(value) {
    if (typeof value === "string") {
        return value.trim();
    }
    if (value && typeof value.get === "function") {
        return textOf(value).trim();
    }
    if (typeof value?.value === "string") {
        return value.value.trim();
    }
    return "";
}

function formatError(error) {
    const message = errorFieldText(error?.msgv1) || errorFieldText(error?.msg);
    if (message.length > 0) {
        return message;
    }

    const expected = errorFieldText(error?.expected);
    const actual = errorFieldText(error?.actual);
    if (expected.length > 0 || actual.length > 0) {
        return `Expected '${expected}', got '${actual}'`;
    }

    return error?.message ?? String(error);
}

function patchDefaultDateTimeFormat() {
    const OriginalDateTimeFormat = Intl.DateTimeFormat;

    // Override Intl.DateTimeFormat to replace "default" with a locale using dots & 24-hour time.
    globalThis.Intl.DateTimeFormat = function DateTimeFormat(locales, options) {
        if (locales === "default" || locales === undefined) {
            locales = "de-DE";
        }

        return new OriginalDateTimeFormat(locales, options);
    };

    Object.setPrototypeOf(globalThis.Intl.DateTimeFormat, OriginalDateTimeFormat);
    globalThis.Intl.DateTimeFormat.prototype = OriginalDateTimeFormat.prototype;
}

async function run() {
    patchDefaultDateTimeFormat();

    const init = await import("../output/_init.mjs");

    globalThis.abap.console.add = (data) => {
        outputBuffer += textOf(data);
        const lines = outputBuffer.split("\n");
        outputBuffer = lines.pop() ?? "";
        for (const line of lines) {
            console.log(`  ${line}`);
        }
    };

    const files = (await readdir(outputDirectory))
        .filter((file) => /\.clas\.testclasses\.mjs$/i.test(file))
        .sort();

    if (files.length === 0) {
        throw new Error("No generated ABAP test-class modules found");
    }

    let total = 0;
    let failed = 0;
    let moduleFailures = 0;

    await init.initializeABAP();

    for (const file of files) {
        let testModule;
        try {
            testModule = await import(new URL(file, outputDirectory));
        } catch (error) {
            moduleFailures++;
            console.error(red(`\nFAIL ${file}: ${formatError(error)}`));
            continue;
        }

        // Generated method metadata doesn't distinguish tests from setup or helper methods.
        const sourceName = file.replace(/\.mjs$/i, ".abap");
        const source = await readFile(new URL(`../src/${sourceName}`, import.meta.url), "utf8");
        const className = sourceName.replace(".testclasses", "");
        const classSource = await readFile(new URL(`../src/${className}`, import.meta.url), "utf8");
        const registry = new Registry().addFiles([
            new MemoryFile(className, classSource), new MemoryFile(sourceName, source)
        ]).parse();
        const testClasses = [...registry.getObjects()][0].getABAPFiles()
            .flatMap((file) => file.getInfo().listClassDefinitions())
            .filter((definition) => definition.isForTesting && !definition.isAbstract)
            .sort((left, right) => left.name.localeCompare(right.name));

        for (const definition of testClasses) {
            const TestClass = testModule[definition.name.toLowerCase()];
            if (typeof TestClass !== "function") throw new Error(`Test class '${definition.name}' was not exported`);
            const methods = definition.methods
                .filter((method) => method.isForTesting)
                .map((method) => method.name.toLowerCase())
                .sort();

            for (const methodName of methods) {
                total++;
                const label = `${TestClass.INTERNAL_NAME}.${methodName}`;
                console.log(`\n=== ${label} ===`);

                try {
                    const instance = await new TestClass().constructor_();
                    const access = instance.FRIENDS_ACCESS_INSTANCE;
                    const testMethod = access?.[methodName] ?? instance[methodName]?.bind(instance);
                    if (typeof testMethod !== "function") {
                        throw new Error(`Generated method '${methodName}' was not found`);
                    }
                    const setup = access?.setup ?? instance.setup?.bind(instance);
                    const teardown = access?.teardown ?? instance.teardown?.bind(instance);
                    try {
                        await setup?.();
                        await testMethod();
                    } finally {
                        await teardown?.();
                    }
                    flushOutput();
                    console.log(`PASS ${label}`);
                } catch (error) {
                    flushOutput();
                    failed++;
                    console.error(red(`FAIL ${label}: ${formatError(error)}`));
                }
            }
        }
    }

    flushOutput();
    if (total === 0) throw new Error("No ABAP FOR TESTING methods found");
    console.log(`\nExecuted ${total} test methods: ${total - failed} passed, ${failed} failed.`);
    if (moduleFailures > 0) console.error(red(`${moduleFailures} test modules failed to load.`));
    if (failed > 0 || moduleFailures > 0) {
        process.exitCode = 1;
    }
}

run().catch((error) => {
    console.error(red(`Test runner failed: ${formatError(error)}`));
    process.exitCode = 1;
});
