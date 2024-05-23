---
title: "Postman代替の「Ain」の紹介"
emoji: "💨"
type: "tech"
topics: ["ain", "shellspec", "aqua"]
published: false
publication_name: "ispec_inc"
---

# Ainの紹介

![](https://github.com/jonaslu/ain/raw/main/assets/logo.svg)

![](https://github.com/jonaslu/ain/raw/main/assets/show-and-tell.gif?raw=true)


[Ain](https://github.com/jonaslu/ain)はターミナル用のAPIクライアントです

使い方は非常に簡単で、リクエストごとに.ainという拡張子のファイルを作成して、`ain`コマンドの引数に渡すだけです。


以前はPostmanを使っていましたが、GUIアプリのインストールとアカウントの管理が面倒で、他チームとのコラボレーションやCI/CDの運用が難しいと感じていました。

さらに、ある程度規模になると有料プランにせざるを得ないのも痛かったです。

APIのリストとリクエストを実際に送って動作確認ができればよく、導入してみた結果弊社での使い方と劇的にマッチしていましたのでご紹介いたします！

# インストール

Go製でmac, windows, linux向けにバイナリが提供されています(Goはすごい)

主要なパッケージマネージャーで提供されているので、インストールも簡単です。

```bash
# brew
$ brew install ain

# go install
$ go install github.com/jonaslu/ain@latest
```

チーム開発で使う際は、バージョン管理できる[aqua](https://aquaproj.github.io/)でもサポートされているのでおすすめです✌️

```yaml
packages:
- name: jonaslu/ain@v1.4.1
```

# 使い方

HTTPのリクエストの必要なパラメーターを.ainファイルに記述するだけです！

めちゃくちゃわかりやすい！！

TOMLに近い形ですが、独自のパーサーを使っているようです。


## ミニマムな例

シンプルなGETの例
```toml file:list-product.ain
[Host]
https://dummyjson.com/products

[Method]
GET

[Query]
limit=10
skip=0

[Backend]
curl

[BackendOptions]
-sS
```

```bash
$ ain list-product.ain | jq
{
  "products": [
    {
      "id": 1,
      "title": "iPhone 9",
      # ...
    },
    {
      "id": 2,
      "title": "iPhone X",
      # ...
    },
    # ...
  ],
  "skip": 0,
  "limit": 10,
  "total": 100
}
```

超シンプルでわかりやすい❣️

`-p`オプションで`[Backend]`のコマンドを出力できて、リクエストを確認できます。これはデバッグも捗りますね！

```bash
$ ain -p base.ain list-product.ain
curl '-sS' \
  'https://dummyjson.comproducts?limit=10&skip=0'
```


もちろんPOSTもできます！
```toml file:add-product.ain
[Host]
https://dummyjson.com/products/add

[Method]
POST

[Body]
{
  "title": "iPhone 9"
}

[Backend]
curl

[BackendOptions]
-sS
```

```bash
$ ain add-product.ain | jq
{
  "id": 101
}
```

## 共通化
HostやBackendなど、プロジェクトで共有の設定がある場合は、別ファイルに切り出して共通化することができます。

```toml file:base.ain
[Host]
https://dummyjson.com

[Backend]
curl

[BackendOptions]
-sS
```

```toml file:use-base-get.ain
[Host]
/products/2
```

## Shellとの組み合わせ

`$()`をainファイルの中に記述することで、shell scriptと組み合わせることもできます。

GraphQLなどBodyがデカい場合などに便利そうですね！

`[Body]`は`#`をコメントとして無視してくれるので、jsonでもコメントを書けます。

```toml file:add-products.ain
[Host]
/products/add

[Method]
POST

[Backend]
$(cat add-product.json) # ここ

[BackendOptions]
-sS
```

```json file:add-products.json
{
    "title": "iPhone 12" # ainならjsonでもコメントを書けちゃう
}
```

## 環境変数

`${}`をainファイルの中に記述することで、環境変数を利用することもできます

```toml file:use-env.ain
[Host]
${API_HOST}/products/${ID}
```

```bash
$ API_HOST=https://dummyjson.com ID=3 ain base.ain use-env.ain | jq
{
  "id": 3,
  "title": "iPhone 11",
  # ...
}
```

また`-e`オプションで.envも読み込んでくれます
```bash
$ cat .env
API_HOST=https://dummyjson.com
ID=3

$ ain -e .env base.ain use-env.ain | jq
{
  "id": 3,
  "title": "iPhone 11",
  # ...
}
```

# APIのE2Eテスト

[shellspec](https://github.com/shellspec/shellspec)を使ってテストを書いてみます

shellspecはRSpecぽくShellのテストを書くことができるツールです！

詳しい説明は割愛しますが、非常に強力な表現力で、CLIツールのテストを書くのに最適です。

こちらの記事にも紹介されています↓
https://zenn.dev/ryo_kawamata/articles/introduce-shellspec



こんな感じで適当なテストを書いてみました。

```bash file:product_spec.sh
Describe "CRUD products"
  Describe "Get product"
    getProductTitlebyID(){
      ID=$1 ain base.ain get-product.ain | jq -r .title
    }

    Parameters
      "#1" 1 "iPhone 9"
      "#2" 2 "iPhone X"
    End

    Example "Get product with ID $1"
      When call getProductTitlebyID $2
      The output should equal "$3"
    End
  End

  Describe "Add product"
    addProduct(){
      ain base.ain add-products.ain | jq -r .id
    }

    It "Add product Correctly"
      When call addProduct
      The output should eq 101
    End
  End
End
```

実行！！

```bash
$ tree ./ain
.
├── add-products.ain
├── add-products.json
├── aqua.yaml
├── base.ain
├── get-product.ain
└── spec
    ├── products_spec.sh
    └── spec_helper.sh

$ shellspec
Running: /bin/sh [sh]
...

Finished in 2.93 seconds (user 0.76 seconds, sys 0.13 seconds)
3 examples, 0 failures
```

無事通りました！

## GitHub Actionsでやってみる

CLIなので、CI/CDでの利用も簡単です!

aquaが最強な理由は、CIとの相性が抜群だから

```yaml file:.github/workflows/api-e2e-test.yml
name: API E2E Test

on:
    push:
        branches:
            - main

jobs:
  ApiE2ETest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

        # - name: 必要に応じてlocalでサーバー起動
        #   run: docker compose up -d

      - uses: aquaproj/aqua-installer@v3.0.1
        with:
          aqua_version: v2.28.0

      - name: Ain Test
        working-directory: ./ain
        env:
          API_HOST: https://dummyjson.com
        run: |
          shellspec
```

やばいくらい簡単！！


# おわりに

これは使いまくっちゃう未来しか見えません！！
