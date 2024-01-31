// Bun Shell
import { $ } from "bun"

// npmパッケージ
import dayjs from "dayjs"

// Bun ビルトイン
import db from "./bun.db" with { type: "sqlite" }

// nodeモジュールは
import { readFileSync } from 'fs'

const now = dayjs().format("YYYY-MM-DD HH:mm:ss")
await $`echo Hello, now is ${now}`
await $`echo ${process.cwd()} > bun-cwd.txt`

const file = readFileSync("bun-shell.js")
console.log(file.toString())
