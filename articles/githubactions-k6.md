---
title: "GitHub Actionsでk6を動かす"
emoji: "💩"
type: "tech"
topics: ["githubactions", "k6"]
published: true
publication_name: "ispec_inc"
---

# モチベーション
インターネット上で開発者がカジュアルに実行できる環境が欲しかったので、GitHub Actionsを使ってみました！

k6用のEC2立てたりECSのtask作ったりLambda作ったりも検討しましたが、選ばれたのはyaml書くだけのActionsでした🍵
(今回はインターネットからパブリックにアクセスできるサーバーに負荷を送るためVPCの中で実行したいなどの制限もありませんでした)

k6はjsでシナリオ書けるので愛用してます😘

# 実装

Actionsのファイル

```yaml:k6-basic-loadtest.yaml
name: K6 Basic LoadTest
on:
  # 手動実行
  workflow_dispatch:

jobs:
  build:
    name: Run k6 test
    runs-on: ubuntu-latest
    timeout-minutes: 300
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Run k6
        # 公式が後悔してるActionsのパッケージ
        # https://github.com/grafana/k6-action
        uses: grafana/k6-action@v0.3.0
        with:
          # 下記参照
          filename: k6/workload.js
        env:
          # 最近秘匿じゃない変数をvarsで参照できるようになった
          SOME_VAR: ${{ vars.SOME_VAR }}
          SOME_SECRET: ${{ secrets.SOME_SECRET }}
```

これだけ、ポイントは `on: workflow_dispatch:` です！
これするとこんな感じでActionsの画面からボタンひとつで実行できるようになります！

[![Image from Gyazo](https://i.gyazo.com/015d1929c807225bfad28bb0a72567f2.png)](https://gyazo.com/015d1929c807225bfad28bb0a72567f2)



k6のシナリオファイルです
jsでかけるのが最高

```js:k6/workload.js

import { check, sleep } from "k6";

import http from 'k6/http';

export const options = {
  stages: [
    { duration: '10m', target: 100 },
    { duration: '20m', target: 1000 },
    { duration: '80m', target: 10000 },
  ],
};

const query = `
query TopPage {
  feedPage(first: 1) {
    edges {
      cursor
      node {
        id
        name
        picture
      }
    }
  }
}
`;

const headers = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${__ENV.SOME_SECRET}`
};

export function setup() {
  if (__ENV.TOKEN === undefined) {
    throw new Error('TOKEN is undefined')
  }
}

export default function () {
  const res = http.post(
    "https://my-owesome-api.com/graphql",
    JSON.stringify({ query }),
    { headers },
  );

  check(res, {
    'no errors': (r) => r.status === 200,
  })
  sleep(3)
}
```

同時接続10000人想定の雑なシナリオ


# 今後
実行結果をどっかに出力して確認するとかやっていきたい
