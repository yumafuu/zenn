---
title: "SSM Parameter StoreのTUIツール「s1m」の紹介 "
emoji: "💡"
type: "tech"
topics: ["go", "aws", "ssm", "tui", "cli"]
published: true
---

# S1Mとは

ssmのパラメータストア(AWS Systems Manager Parameter Store)をTUIで操作するツールです

https://github.com/yumafuu/s1m

ssmだと長いので中間の`s`が1文字なので`s1m`という名前にしました

ちなみに、k8sやi18nやs1mのように、先頭と末尾のみ残して、間に残された文字をその文字数（桁数）で省略する表現を「ヌメロニム(numeronym)」というらしいです👀


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

HomeBrew経由か`go install` かaquaで簡単にインストールすることができます

```bash
# homebrew
$ brew install yumafuu/yumafuu/s1m

# go install
$ go install github.com/yumafuu/s1m@latest

# aqua
$ aqua g -i yumafuu/s1m
```

## 機能 & 使い方

* 一覧
* 新規作成
* 編集
* 削除
* 名前のコピー
* 値のコピー


シンプルで使いやすいので、SSMのパラメータストアを操作する際にぜひ使ってみてください

# Tviewの紹介

s1mはgoでTUIアプリを簡単に作れる `tview` というライブラリを使いました。

https://github.com/rivo/tview

TUIアプリに必要なウィジェットが揃っていて、ウィジェット操作のためのイベントも簡単に設定できます

k8s操作のためのTUIアプリ `k9s` やGitHubのcliアプリ`cli/cli`にもこのライブラリが使われています

Wikiが充実していて、大体のことはWikiを見れば実装できると思います。

https://github.com/rivo/tview/wiki

## s1mの実装

使ってるウィジェットは以下の通り

[![Image from Gyazo](https://i.gyazo.com/3e4b0dd0f09b36419e33f2c37d91ff1c.png)](https://gyazo.com/3e4b0dd0f09b36419e33f2c37d91ff1c)

- `tview.Flex`
- `tview.TreeView`
- `tview.InputField`
- `tview.TextView`
- `tview.TextArea`

の5つです


それぞれ簡単に紹介していきます


### tview.Flex

`Flex` はウィジェットを配置するためのコンテナです

![](https://github.com/rivo/tview/raw/master/demos/flex/screenshot.png)
https://github.com/rivo/tview/wiki/Flex


`AddItem` でウィジェットを追加していきます

`flex.AddItem(ウィジェット, 固定サイズ, 比率, フォーカス)`という形で追加します。が、正直ロジックは完全にわかってないので、色々試しながらいい感じになるように実装しました

https://github.com/rivo/tview/blob/a64fc48d7654432f71922c8b908280cdb525805c/flex.go#L82-L99


### tview.TreeView

`TreeView` は画像のようなツリー構造を表示するためのウィジェットです

![](https://github.com/rivo/tview/raw/master/demos/treeview/screenshot.png)

https://github.com/rivo/tview/wiki/TreeView


`GetCurrentNode` でカーソルがあるノードを取得できたり、`InputCapture`でキー入力を受け付けることができます。

この二つを組み合わせることで、カーソルがあるノードを取得して、そのノードに対して操作を行うことができます。

s1mでも操作の種類とリソースを取得するのに使用しています


### tview.TextView

`TextView` はテキストを表示するためのウィジェットです

![](https://github.com/rivo/tview/raw/master/demos/textview/screenshot.png)

https://github.com/rivo/tview/wiki/TextView

複数行のテキストを表示するために使用します

`[color]some text`とすることで色を変えることができます。

`TextView.SetDoneFunc`で入力完了した時の処理を設定できます

### tview.TextArea

`TextArea` は複数行のテキストの入力を受け付けるためのウィジェットです

![](https://github.com/rivo/tview/raw/master/demos/textarea/screenshot.png)

https://github.com/rivo/tview/wiki/TextArea

TextViewと同じく色をつけたり、`TextArea.SetDoneFunc`で入力完了した時の処理を設定できます

### tview.InputField

`InputField` は入力を受け付けるためのウィジェットです

![](https://github.com/rivo/tview/raw/master/demos/inputfield/screenshot.png)

https://github.com/rivo/tview/wiki/InputField

HTMLでいうところの `<input type="text">` みたいなものです

一行の短いテキストを表示するのに使います

s1mでは、コンファームのための`y/n`の表示と入力を受け付けるために使用しています

vimmerのために`:wq`でも`y`の入力を受け付けるようにしています✋

# 終わりに

s1mはドッグフーディングしてますが、体験が良いので是非触ってみてください！
フィードバックや要望があればお気軽にIssueを立ててください🙇‍♂️


そしてtviewも使いやすいので、TUIアプリを作る際には是非使ってみてください！

