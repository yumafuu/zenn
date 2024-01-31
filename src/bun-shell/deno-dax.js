// dax
import $ from "https://deno.land/x/dax@0.38.0/mod.ts";

// npm パッケージ
import dayjs from "npm:dayjs"

// Denoパッケージ
import { DB } from "https://deno.land/x/sqlite/mod.ts"

// nodeモジュール
import process from "node:process";
import { readFileSync } from "node:fs";

const now = dayjs().format("YYYY-MM-DD HH:mm:ss")
await $`echo Hello, now is ${now}`
await $`echo ${process.cwd()} > deno-cwd.txt`

const file = readFileSync("deno-dax.js")
console.log(file.toString())
