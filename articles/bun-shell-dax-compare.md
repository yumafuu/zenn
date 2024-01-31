---
title: "Denoと比較しながらBun Shellを見てみる"
emoji: "🧄"
type: "tech"
topics: ["bun", "deno", "dax"]
published: true
---

# Bun Shellが出た

https://x.com/bunjavascript/status/1748587391433253044?s=20

JavaScript, TypeScriptでShellが記述可能になるものです!
[google/zx](https://github.com/google/zx)がbun本体に取り込まれたような感じですね！


# 何が嬉しいのか

## Shellを書かなくていい

Bashはツラい
ifで条件分岐するのも一苦労です

JavaScriptは読み書きできる人が多いのでShellの代わりにするには持ってこいだと思います


## 型の恩恵

TypeScriptがそのまま実行可能なので、型が使えます！

動的型付けアレルギーの人にも納得して使ってもらえます

## クロスプラットフォーム

Mac, Linux, Windowsで動きます。

自作のパーサが実装されていて、OSの差分を吸収しているポイですね(zig全くわからん)

https://github.com/oven-sh/bun/blob/main/src/shell/shell.zig

# DenoのDaxと開発者体験で比較してみる

Bun Shellと同等の機能がDenoの[dax](https://github.com/dsherret/dax)で提供されています。
これも[deno_task_shell](https://github.com/denoland/deno_task_shell)という独自のパーサーを使っていてクラスプラットフォームで動作します。

筆者はDenoが大好きでしたが、Bun Shellをきっかけにいろいろ調べて見たらbunよくね？ってなったので比較して見たいと思います。

ps) 自分はdaxを使ってAWS SSMのCLIツールを作成したことがあります
https://zenn.dev/ispec_inc/articles/denosm-ssm-parameterstore

## 機能

基本的には両者大きく変わらず、基本的なシェルコマンド(`ls`, `echo`, `mv`, `|`, `>`など)とヘルパーメソッドの提供がされています

### dax

```js:basic.js
import $ from "https://deno.land/x/dax/mod.ts";

await $`echo 5`; // 5

// outputting 1 to stdout and running a sub process
await $`echo 1 && deno run main.ts`;


// outputs
const result = await $`echo 1`.text();
console.log(result); // 1

const result = await $`echo '{ "prop": 5 }'`.json();
console.log(result.prop); // 5

```

daxはだいぶ高機能です。
特徴的なのはインタラクション(`$.prompt`, `$.select`, `$.confirm`, `$.progress`など)に関するメソッドが提供されていることです
CLIツールならdaxだけで組み立てることができます

```js:cli.js
import $ from "https://deno.land/x/dax@0.38.0/mod.ts";

const options = [
  { ja: "吉村家", en: "yoshimuraya" },
  { ja: "杉田家", en: "sugitaya" },
  { ja: "たかさご家", en: "takasagoya" },
]

const index = await $.select({ message: "What's your favourite shop?", options: options.map((o) => o.ja) });
const selected = options[index]

let shop
const pb = $.progress("Fetching...");
await pb.with(async () => {
  const res = await fetch(`https://ramen-api.dev/shops/${selected.en}`)
  shop = (await res.json()).shop
});

const img = shop.photos[0].url
await $`curl -s ${img} -o ${selected.en}.jpg && imgcat ${selected.en}.jpg`
const result = await $.confirm({ message: `${selected.ja}を食べ行きますか?`});

console.log(result);
```
[![Image from Gyazo](https://i.gyazo.com/84b8be94dfadcd84355723c858e1eb7d.gif)](https://gyazo.com/84b8be94dfadcd84355723c858e1eb7d)

参照
- [dax](https://github.com/dsherret/dax?tab=readme-ov-file)

### Bun

```js:basic.js
import { $ } from "bun";

await $`echo 5`; // 5
const welcome = await $`echo "Hello World!"`.text();
console.log(welcome); // Hello World!\n

const result = await $`echo "Hello World!" | wc -w`.text();
console.log(result); // 2\n
```

Bun Shellはまだアルファ版のため基本的なまだ機能しかありませんが、十分Shellの代用をできるレベルのものだと思います

特徴的なのは`.bun.sh`という拡張子をBun Shellで実行できます。
```bash
$ cat script.bun.sh
echo Hello, Bun!
ls

$ bun ./script.bun.sh
Hello, Bun!
script.bun.sh
bun.db
index.js
```
既存のシェルスクリプトを置き換える時に便利なのかな、、？(あんまり用途がわかってない)

参照
- [Bun Shell](https://bun.sh/docs/runtime/shell)

ちなみに、daxはBun Shellの発表してすぐにリダイレクトやパイプ処理のサポートをリリースしていました💨
https://github.com/dsherret/dax/releases/tag/0.38.0


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

Bunには[autoimport](https://bun.sh/docs/runtime/autoimport)機能があり、node_modulesが存在しなかったら勝手にインストールしてくれてグローバルにキャッシュしてくれます。
この時node_modulesは作られません！！

またBunはNodeとの完全な互換を目指しているので、多くのnodeのapiがビルトインで使えます

こちらで詳しく互換性が紹介されています
https://bun.sh/docs/runtime/nodejs-apis


```js:bun.js
// Bun Shell
import { $ } from "bun"

// npmパッケージ
import sqlite3 from "sqlite3"

// Bun ビルトイン(コンパイル可能)
import db from "./bun.db" with { type: "sqlite" }

// nodeモジュールは基本何もせず動く
```

## バイナリサイズ
CLIツールとして配布したい時にユーザーにランライムを要求したくない(されたくない)ですが、両者ともにスタンドアロンのバイナリにコンパイル可能です


```bash
# Deno
$ echo 'console.log("Hello")' > deno-bin.js
$ deno compile -A deno-bin.js

# Bun
$ echo 'console.log("Hello")' > bun-bin.js # bunっていう名前のバイナリは作れないらしい
$ bun build bun-bin.js --compile

$ ls -l deno-bin bun-bin
.rwxrwxrwx  94M yuma 31 Jan  9:41 bun-bin
.rwxrwxrwx 139M yuma 31 Jan  9:41 deno-bin
```

どちらもだいぶ大きいですがDenoの方が約1.5倍大きいです。

Bunがどうかは分かりませんが、DenoでできたバイナリはDeno自身を内包しているので大きくなっているらしいです

Denoはnpmのパッケージも含め、外部パッケージをコンパイルできるのでそこは現状優位ですね！


# おわりに

BunはautoimportとNode互換のおかげでめちゃくちゃ記述量が減り、めちゃくちゃ体験がいいですね！

とはいえ、コンパイルする場合にDenoならnpmパッケージが使えたり、package.jsonとnode_modulesなしで開発ができるためまだまだ開発者体験は良いなぁという所感です！

Bun Shellをはじめとして両者ともに開発がめちゃくちゃ活発なので今後が楽しみです🤩


# おまけ

クロスプラットフォームBun肉まん

https://x.com/bunjavascript/status/1749274910856445974?s=20
https://x.com/bunjavascript/status/1749275619811271141?s=20
