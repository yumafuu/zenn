---
title: "Denoと比較しながらBun Shellを見てみる"
emoji: "👀"
type: "tech"
topics: ["bun", "deno", "dax"]
published: false
---

# Bun Shellが出た

https://x.com/bunjavascript/status/1748587391433253044?s=20

[google/zx](https://github.com/google/zx)がbun本体に取り込まれたような感じですね！


# 何が嬉しいのか

## Shellを書かなくていい
Bashはツラいです。
JavaScriptの世界でShellでやりたいことが


## 型の恩恵
TypeScriptがそのまま実行可能なので、型が使えます。

## クロスプラットフォーム

# DenoのDaxと開発者体験で比較してみる

筆者はDenoが大好きでしたが、Bun Shellをきっかけにいろいろ調べて見たらbunよくね？ってなったので比較して見たいと思います。

Bun Shellと同等の機能がDenoの[dax](https://github.com/dsherret/dax)で提供されています。
これも(deno_task_shell)[https://github.com/denoland/deno_task_shell]という独自のパーサーを使っていてクラスプラットフォームで動作します。


## 機能
できることは大きく変わらないです

## 外部パッケージ

ここが大きく変わります

### Deno

DenoはパッケージをURLから直接importします。
npmパッケージなら`npm:` プレフィックスを指定してimportできます。
nodeのビルトインモジュールも `node:`プレフィックスを指定importして使えますが


```js:deno.js
// dax
import $ from "https://deno.land/x/dax/mod.ts";

// npm パッケージ
import sqlite3 from "npm:sqlite3"

// Denoパッケージ
import { DB } from "https://deno.land/x/sqlite/mod.ts"

// nodeモジュール
import { process } from "node:process";
import { readFileSync } from "node:fs";

```

### Bun

Bunには[autoimport](https://bun.sh/docs/runtime/autoimport)機能があり、node_modulesが存在しなかったら勝手に`bun install` してくれてグローバルにキャッシュしてくれます。
この時node_modulesは作られません！！

```js:bun.js
// Bun Shell
import { $ } from "bun"

// npmパッケージ
import sqlite3 from "sqlite3"

// Bun ビルトイン
import db from "./bun.db" with { type: "sqlite" }

// nodeモジュールは何もせず動く
// 互換性はこちら: https://bun.sh/docs/runtime/nodejs-apis
```

## バイナリサイズ
CLIツールとして配布したい時にユーザーにランライムを要求したくない(されたくない)ですが、両者ともにスタンドアロンのバイナリにコンパイル可能です

現状BunのAutoImportはcompileには使えないので注意です


```bash
# Deno
$ deno compile -A deno-dax.js

# Bun
$ bun build bun-shell.js --compile
```



# おわりに
DenoはDeno Deployが非常に強力です



# おまけ

クロスプラットフォームを乗っ取ったBun肉まん

https://pbs.twimg.com/media/GEasPb1bMAAlfNs?format=jpg&name=small
https://pbs.twimg.com/media/GEaslBDaIAAdePq?format=png&name=small
https://pbs.twimg.com/media/GEas4KIaoAAUibJ?format=png&name=360x360
