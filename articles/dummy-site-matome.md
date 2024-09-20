---
title: "たまに使うダミーデータを返すサイトのまとめ"
emoji: "🤖"
type: "tech"
topics: ["dummy", "吉村家"]
published: true
publication_name: "ispec_inc"
---

# はじめに

開発用データとかデータ操作系のツールとかの検証に使えるダミーデータを返すサイトをまとめてみました！

ほぼ自分用のメモですが、他の方にも役立てば幸いです

他におすすめのサイトがあれば教えてください！

# 画像

## robohash

https://robohash.org

ランダムなロボットの画像を返してくれるサイトです。

`https://robohash.org/${id}` にアクセスとするとidに対してユニークなロボットの画像を返してくれます。

[![Image from Gyazo](https://i.gyazo.com/2982c8e4add1274025636d043f56bfe6.png)](https://gyazo.com/2982c8e4add1274025636d043f56bfe6)

画像がとても可愛いです(？)

## dummyjson

https://dummyjson.com/docs/image

大きさ、背景、色、テキスト、フォント、フォントサイズを指定して画像を返してくれるサイトです。



```bash
# 画像
"
https://dummyjson.com/image/${SIZE}/${BACKGROUND}/${COLOR}/
    ?text=${TEXT}
    &type=${TYPE(=png|webp|jpeg)}
    &fontFamily=${FONT}
    &fontSize=${FONT_SIZE}
"

# HASHからアイコンを作成もできます
"
https://dummyjson.com/icon/${HASH}/${SIZE}
    ?type=${TYPE(=png|svg)}
"
```

[![Image from Gyazo](https://i.gyazo.com/c111c1cdc1dda2be7e29eb7e035b1de7.png)](https://gyazo.com/c111c1cdc1dda2be7e29eb7e035b1de7)


## fakeimg

https://fakeimg.pl

dummyjsonと同じく指定したサイズ、テキスト、色、フォントの画像を返してくれるサイトです。

[![Image from Gyazo](https://i.gyazo.com/1be8e02a27bb3cfb3d852b7f85ab2208.png)](https://gyazo.com/1be8e02a27bb3cfb3d852b7f85ab2208)

他にも色々パラメーターを指定できます
```html
<img src="https://fakeimg.pl/300/">
<img src="https://fakeimg.pl/250x100/">
<img src="https://fakeimg.pl/250x100/ff0000/">
<img src="https://fakeimg.pl/350x200/ff0000/000">
<img src="https://fakeimg.pl/350x200/ff0000,128/000,255">
<img src="https://fakeimg.pl/350x200/?text='Hello World'">
<img src="https://fakeimg.pl/200x100/?retina=1&text=こんにちは&font=noto">
<img src="https://fakeimg.pl/350x200/?text=World&font=lobster">
```


# JSON

## ramen-api

https://ramen-api.dev

[Hono](https://hono.dev)作者の@yusukebeさんが作成したラーメン屋の情報を返すAPIです。

RESTfulとGraphQLの両方で利用できます。

ソースはこちら
https://github.com/yusukebe/ramen-api

ps.
最初のお店は家系総本山の吉村家です

[![Image from Gyazo](https://i.gyazo.com/f62870a450c0e4c0d72be904be37fa22.jpg)](https://gyazo.com/f62870a450c0e4c0d72be904be37fa22)

## jsonplaceholder

RESTfulなJSONのダミーのAPIを提供してくれるサイトです。

https://jsonplaceholder.typicode.com

```bash
$ curl https://jsonplaceholder.typicode.com/todos/1
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

ps.

typicodeさんは他にもjsonファイルをREST APIとしてサーブできる[json-server](https://github.com/typicode/json-server)やJavaScriptでJSONファイルをデータベースとしてRead,Writeできるようにする[lowdb](https://github.com/typicode/lowdb)を作っておられ、とても便利です。

## httpbin

https://httpbin.org

以下の通りHTTPの基本的な機能を提供してくれています。
[![Image from Gyazo](https://i.gyazo.com/34592dab18cf746b36c8d6d32659e9cc.png)](https://gyazo.com/34592dab18cf746b36c8d6d32659e9cc)

認証やリダイレクト、エラーなどのテストに使えるのが特徴です。

スタンドアロンなサーバーとしても起動できるのが便利です。

```bash
$ docker run -p 80:80 kennethreitz/httpbin
```

## dummyjson

https://dummyjson.com

本日二度目の登場

かなり大きめの構造化されたJSONを返してくれたり、カスタムレスポンスを永続化してくれたりするのが特徴的です。

保存してみました

[![Image from Gyazo](https://i.gyazo.com/e9405a8f0181d427e7ee62c711654a69.png)](https://gyazo.com/e9405a8f0181d427e7ee62c711654a69)

```bash
$ curl https://dummyjson.com/c/bc27-ae3c-45ff-b04a
{"name":"yumafuu"}
```

---

以上です！

他にあれば追記していきます
