---
title: "macでsixel入りtmuxをBrewで入れる"
emoji: "🐡"
type: "tech"
topics: ["sixel", "tmux"]
published: false
publication_name: "ispec_inc"
---

# tmuxにsixelが入った！！！！！！！！！！！！！
やったー！！！

https://raw.githubusercontent.com/tmux/tmux/3.4/CHANGES

[![Image from Gyazo](https://i.gyazo.com/8464a71c0d3f92f18a549465b17b1049.png)](https://gyazo.com/8464a71c0d3f92f18a549465b17b1049)

sixelはターミナルで画像を表示するプロトコルで、iterm2などでは `imgcat`などで画像が表示できます！


# 早速Brew Install

```bash
$ brew install tmux
```

では無理なんですね、、、、

画像の通りビルドのオプションで `--sixel-enable`を指定しないといけません。

Brewではどうビルドしてるのかというと、

https://github.com/Homebrew/homebrew-core/blob/c5de89fc9934080854f8bfbcd999109ee2c738c4/Formula/t/tmux.rb#L52-L56

--enable-sixelが入ってないです

# 書き換え

Brewの設定を書き換えてインストールしてみましょう！
上のファイルの55行目に`--enable-sixel `をつっこめばいいので `sed` で入れるだけで良いです

```bash
$ brew --build-from-source --formula ファイル`
```
とすれば、ファイルからビルドをできます

``` bash
$ curl -s https://raw.githubusercontent.com/Homebrew/homebrew-core/c5de89fc9934080854f8bfbcd999109ee2c738c4/Formula/t/tmux.rb > /tmp/tmux.rb && \
    sed -i '' '55s/^/ --enable-sixel\'$'\n/' /tmp/tmux.rb
$ brew install --build-from-source --formula /tmp/tmux.rb
```

以上！！！

# 終わりに

https://github.com/Homebrew/homebrew-core/pull/162644

プルリクが上がってるので、もうすぐマージされそうですが、勉強も兼ねてやってみました✌️
