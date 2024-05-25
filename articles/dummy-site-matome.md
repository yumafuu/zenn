---
title: "たまに使うダミーデータを返すサイトのまとめ"
emoji: "🤙"
type: "tech"
topics: ["dummy"]
published: false
publication_name: "ispec_inc"
---

# はじめに

開発用データとかデータ操作系のツールとかの検証に使えるダミーデータを返すサイトをまとめてみました！


# 画像
## fakeimg

https://fakeimg.pl

## robohash

https://robohash.org

# JSON

## jsonplaceholder

jsonファイルをRestAPIとしてサーブできる[json-server](https://github.com/typicode/json-server)やJSONファイルをデータベースとしてRead,Writeできるようにする[lowdb](https://github.com/typicode/lowdb)を作っているtypicodeさんが運営しているサイトです。

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

## httpbin

https://httpbin.org

## dummyjson

https://dummyjson.com

## ramen-api

https://github.com/yusukebe/ramen-api

