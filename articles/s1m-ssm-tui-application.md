---
title: "SSM Parameter StoreのTUIツール「s1m」の紹介 "
emoji: "💡"
type: "tech"
topics: ["aws", "ssm", "tui", "tview" ]
published: false
---

# S1Mとは

ssmのパラメータストア(AWS Systems Manager Parameter Store)をTUIで操作するツールです

僕が作りました
https://github.com/yumafuu/s1m

ssmだと長いので中間の`s`が1文字なので`s1m`という名前にしました

ちなみに、k8sやi18nやs1mのように、先頭と末尾のみ残して、間に残された文字をその文字数（桁数）で省略する表現を「ヌメロニム(numeronym)」というらしいです


https://ja.wikipedia.org/wiki/ヌメロニム



# 使い方

Demoを見てもらうとわかりやすいと思います

[![Image from Gyazo](https://i.gyazo.com/391912839a7a9cd66a935e54a37e4c15.gif)](https://gyazo.com/391912839a7a9cd66a935e54a37e4c15)

Vim風のキーバインドで操作できます。

| Key     | Description                          |
|---------|--------------------------------------|
| `j`     | 下に移動                             |
| `k`     | 上に移動                             |
| `i`     | カーソル下のパラメータを編集         |
| `d`     | カーソル下のパラメータを削除         |
| `o`     | 新しいパラメータを作成               |
| `c`     | カーソル下のパラメータの値をコピー   |
| `y`     | カーソル下のパラメータの名前をコピー |
| `r`     | リロード                             |
| `<ESC>` | 編集モードから抜ける                 |


## インストール

Go製のバイナリをGitHub Releaseにおいています

HomeBrew経由か`go install` で簡単にインストールすることができます

```bash
# homebrew
$ brew install yumafuu/yumafuu/s1m

# go install
$ go install github.com/yumafuu/s1m@latestl
```

## 機能 & 使い方

* 一覧
* 新規作成
* 編集
* 削除
* 名前のコピー
* 値のコピー


## キーバインド

s1m inspired by vim key bindings.

| Key     | Description                                 |
|---------|---------------------------------------------|
| `j`     | Move down                                   |
| `k`     | Move up                                     |
| `i`     | Edit Parameter under the cursor             |
| `d`     | Delete Parameter under the cursor           |
| `o`     | Create new Parameter                        |
| `c`     | Copy the Value under the cursor             |
| `y`     | Copy the Name of Parameter under the cursor |
| `<ESC>` | Exit from the input box                     |


# 実装
goでtuiアプリを簡単に作れる `tview` というライブラリを使いました。

https://github.com/rivo/tview

TUIアプリに必要なウィジェットが揃っていて、ウィジェット操作のためのイベントも簡単に設定できます

簡単に紹介します

```go

```
