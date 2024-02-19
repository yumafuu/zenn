---
title: "sixel対応tmuxをBrewで入れる！"
emoji: "👶"
type: "tech"
topics: ["sixel", "tmux"]
published: true
publication_name: "ispec_inc"
---

# tmuxにsixelが入った！！！！！！！！！！！！！
やったー！！！

[![Image from Gyazo](https://i.gyazo.com/8464a71c0d3f92f18a549465b17b1049.png)](https://gyazo.com/8464a71c0d3f92f18a549465b17b1049)

https://raw.githubusercontent.com/tmux/tmux/3.4/CHANGES

sixelはターミナルで画像を表示するプロトコルで、`img2sixel`やiterm2の`imgcat`などで画像が表示できます！


# 早速Brew Install

```bash
$ brew install tmux
```

ではまだ無理なんですね、、、、

画像の通りビルドのオプションで `--sixel-enable`を指定しないといけません。

Brewのビルドオプションをみてみると、

https://github.com/Homebrew/homebrew-core/blob/c5de89fc9934080854f8bfbcd999109ee2c738c4/Formula/t/tmux.rb#L49-L76

`--enable-sixel`が入ってないです

# 対応

なければ足せばいいじゃない。


ってことでBrewの設定を書き換えてインストールしてみましょう！

Brewでは
```bash
$ brew install --build-from-source --formula ファイル
```
とすれば、ファイルからパッケージをビルドをできます


今回は55行目のargsに`--enable-sixel `をつっこめばいいので `sed` で入れてみます

```bash
$ curl -o /tmp/tmux.rb https://raw.githubusercontent.com/Homebrew/homebrew-core/c5de89fc9934080854f8bfbcd999109ee2c738c4/Formula/t/tmux.rb
$ sed -i '' '55s/^/ --enable-sixel\'$'\n/' /tmp/tmux.rb
$ brew install --build-from-source --formula /tmp/tmux.rb
```

以上！！！

[![Image from Gyazo](https://i.gyazo.com/b6f167c2f4263cd1ff866b682a6df72e.png)](https://gyazo.com/b6f167c2f4263cd1ff866b682a6df72e)

# 終わりに

https://github.com/Homebrew/homebrew-core/pull/162644

プルリクが上がってるので、もうすぐマージされそうですが、我慢できずにやってみました✌️
