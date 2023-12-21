---
title: "SSM Parameter StoreのFuzzy Finderを作った"
emoji: "🦖"
type: "tech"
topics: ["deno", "ssm", "aws", "dax", "cliffy", "fzf", "ghr"]
published: false
publication_name: "ispec_inc"
---

# モチベーション

ECSでサーバーを立てる時の環境変数に入れる値の置き場として AWS Systems Manager Parameter Storeが使えますが、値の確認がめんどくさい！

ってことでFuzzy FindできるCLIを作りました🦖

# 作ったもの


![Usage](https://github.com/YumaFuu/denosm/assets/32477095/03f42c87-0307-4476-81c1-c27484ed29bf)

https://github.com/YumaFuu/denosm

denoとBrewでインストールできます

なんとdenoがシングルバイナリにコンパイルできるのでBrewでも配信することにしました
(denoでコンパイルしたバイナリはdeno自信を含むのでクソデカくなります)


# 使用技術

ベースはみんな大好き[ デノ](https://deno.com/)(ディノが正しいらしい) です🦖
そのシンプルさから愛用していますが、特にこういったCLIツールを作るのにはもってこいです

## Dax

https://github.com/dsherret/dax

Dax はDenoで動くShellツールです。

shellでパイプやリダイレクトを頑張って書くのは読むのも書くのも大変ですがそれを解決してくれるツールです。


```javascript
import $ from "https://deno.land/x/dax/mod.ts";

const list = await $`aws ssm describe-parameters --profile ${profile}`.json();
```

こんな感じでaws cliの結果をjsonをjsでゴニョゴニョしています

zennでもいくつかの記事が上がっていますので、要チェック！！

https://zenn.dev/hashrock/articles/5dae2e171533a6

https://zenn.dev/impactaky/articles/d1d9876f6e1128

## Cliffy

DenoでCLIツールを作る際のフレームワークです

[https://cliffy.io/](Cliffy)

https://github.com/c4spar/deno-cliffy

smコマンドでは、Command, tty, pressを使っています。

```javascript
import { colors, tty, } from "https://deno.land/x/cliffy@v1.0.0-rc.3/ansi/mod.ts";

// ...
tty.cursorHide();

// ...
tty
    .cursorTo(0, 0)
    .eraseScreen();

// ...
highlighted += colors.bold.blue(s);

```

promptやtable描画などもあるのでDenoでCLIツールを作る時はこれ使えば間違い無いです✌️



## fzf-for-js

[fzf](https://github.com/junegunn/fzf)のアルゴリズムのJS実装です
fzfはコマンドラインで愛用していますが、今回はDenoなので[ esm.sh ](https://esm.sh/)で配信されている[fzf-for-js](https://github.com/ajitid/fzf-for-js)を使いました


```javascript
const fzf = new Fzf(options);
let hits = fzf.find(search);
```
といった感じでかなり簡単に曖昧検索が実装できます


## ghr

https://github.com/tcnksm/ghr

GitHub Release に複数のアーティファクトをアップロードするツールで体験が良かったです

denoは複数のプラットフォームに向けてバイナリを作成できるので、それをリリースしました

actions用のパッケージがあったのでこちらを使っています

https://github.com/fnkr/github-action-ghr
```yaml
release:
    name: Release Packages
    runs-on: ubuntu-latest
    needs:
      - compile
    steps:
      - uses: actions/checkout@v3

      - { uses: actions/download-artifact@v3, with: { name: x86_64-unknown-linux-gnu,  path: release/ } }
      - { uses: actions/download-artifact@v3, with: { name: x86_64-apple-darwin,       path: release/ } }
      - { uses: actions/download-artifact@v3, with: { name: aarch64-apple-darwin,      path: release/ } }

      - name: Release
        uses: fnkr/github-action-ghr@v1
        env:
          GHR_PATH: release/
          GITHUB_TOKEN: ${{ secrets.GH_TOKEN }}

```


# 終わりに

かなり簡単に満足いくものが作れました

値の作成、更新の昨日もつけて行けたりしたらもっと使いやすくなりそうなのでぼちぼちやっていきたいです🚶

