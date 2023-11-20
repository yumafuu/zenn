---
title: "Gatherでも歩くのがしんどいのでテレポートボタンを作った"
emoji: "🏃"
type: "tech"
topics: ["gathertown", "リモートワーク", "scriptautorunner"]
published: true
publication_name: "ispec_inc"
---

# まず

リモートワークを最適化してしまった怠惰なエンジニアの方々(褒めてる)が最初に直面する課題が運動不足だと思います。

今回はリモートワークで必要不可欠なバーチャルオフィスでその運動不足をさらに加速させる方法をご紹介します！

# Gatherとは
リモートワークを支える、可愛いアバターとゲームのような世界観のバーチャルオフィスです！
[Gather](https://ja.gather.town/features)

ispecでの活用事例を公式に取り上げていただいてたりもします✌️

https://ja.gather.town/blog/jp-ispec

# したこと

## なぜしたのか

当たり前ですが、Gatherはオフィスなので移動が発生します

こんな感じ

[![Image from Gyazo](https://i.gyazo.com/cefb6a275346f1c52f5bb2e83ece8429.gif)](https://gyazo.com/cefb6a275346f1c52f5bb2e83ece8429)

...遅い！歩くのが遅い！！この短い距離でも2000msくらい待たされてしまいました

危うくvimの設定を見直してしまうところでした

## 方針

テレポートのボタンを配置します(ブラウザ限定ですが)
[![Image from Gyazo](https://i.gyazo.com/de5b3dfca6a0d1618cfabb3e0f52b036.png)](https://gyazo.com/de5b3dfca6a0d1618cfabb3e0f52b036)


gatherはwindowに`game` というObjectを生やしてくれているようで、consoleから色々いじいじできます
[Document](http://gather-game-client-docs.s3-website-us-west-2.amazonaws.com/classes/Game.html)

今回もこの `game.teleport` 関数を使って実装します！

この記事は[クラメソ様の記事](https://dev.classmethod.jp/articles/gather-matome-three-api/)の記事からインスパイアを受けました🙏

ありがとうございます！

## 実装

クリックしたら `game.teleport` を呼び出すDOMを`position: absolute` で配置します(わりかし雑な実装です)
```js
const teleportButton = (text, x, y) => {
  const btn = document.createElement('button');
  btn.innerHTML = text;
  // 半透明のいい感じの色にする
  btn.style = `border: none; outline: none; font: inherit; color: inherit; background-color: rgba(51, 51, 51, 0.4); color: #fff; padding: 5px 12px;`
  btn.onclick = (() => {
    // 今いるmapのIDを取得
    const mapId = window.game.getMyPlayer().map;
    window.game.teleport(mapId, x, y);
  })

  return btn;
}

const e = document.createElement('div');
e.style = `position: absolute; margin-top: 60px; margin-left: 30px; z-index: 1;`

e.appendChild(teleportButton('MyDesk', 78, 44));
e.appendChild(teleportButton('もくもく', 68, 23));
e.appendChild(teleportButton('全社', 47, 28));
e.appendChild(document.createElement('br'));
// ...

document.getElementById('root').appendChild(e);
```

teleportButtonに渡す値はconsoleで以下を実行すると調べられます

```js
// 今自分のアバターがいる位置を取得する
{ x: game.getMyPlayer().x, y: game.getMyPlayer().y }
```

こちらをページロード時点で実行すれば、テレポート用のボタンが生成されるというわけです。
毎回consoleで実行するのは、信じられないくらいめんどくさいので[ScriptAutoRunner](https://chrome.google.com/webstore/detail/scriptautorunner/gpgjofmpmjjopcogjgdldidobhmjmdbm?hl=ja)で実行してもらいます。

UI可愛いですね

[![Image from Gyazo](https://i.gyazo.com/1213e26b65a126d558f3f605ef70e73c.png)](https://gyazo.com/1213e26b65a126d558f3f605ef70e73c)


上のjsをはっ付けておきます

# 完成系

うおおおお！！！！！！！

[![Image from Gyazo](https://i.gyazo.com/80a45b0863dc3390ff6fd23cf58338fb.gif)](https://gyazo.com/80a45b0863dc3390ff6fd23cf58338fb)

これでバーチャル健康診断の値をもっと悪くすることができました
