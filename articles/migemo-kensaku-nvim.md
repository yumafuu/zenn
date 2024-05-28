---
title: "ローマ字で日本語検索する by migemo (with vim)"
emoji: "🐸"
type: "tech"
topics: ["migemo", "vim"]
published: true
publication_name: "ispec_inc"
---

# migemoとは?

> Migemo はローマ字のまま日本語をインクリメンタル検索するため のツールです。
かな漢字変換をすることなく日本語のインクリメンタル検索を快適に行うことができます。

* [Migemo: ローマ字のまま日本語をインクリメンタル検索](http://0xcc.net/migemo/)

つまり、`検索`を`kensaku`という入力で検索できるようになります。

最初はEmacsの機能としてリリースされたようです(たぶん)
https://github.com/emacs-jp/migemo

js実装もあります

https://github.com/oguna/jsmigemo

## やってみる

jsmigemoがnpxで対話的に使えるので試してみます。

```bash
$ npx jsmigemo
QUERY: kensaku
PATTERN: (kensaku|けんさく|ケンサク|建策|憲[作冊]|検索|献策|研削|羂索|ｋｅｎｓａｋｕ|ｹﾝｻｸ)

QUERY: hajimemasite
PATTERN: (hajimemasite|はじめまして|ハジメマシテ|初めまして|始めまして|ｈａｊｉｍｅｍａｓｉｔｅ|ﾊｼﾞﾒﾏｼﾃ)

QUERY: aaa
PATTERN: (aaa|あああ|アアア|ａａａ|ｱｱｱ)
```

`kensaku`というqueryで`(kensaku|けんさく|ケンサク|建策|憲[作冊]|検索|献策|研削|羂索|ｋｅｎｓａｋｕ|ｹﾝｻｸ)`という正規表現が生成されました。

仕組みは単純で、約5GBのバカデカ辞書からパターンを生成してるようです。

https://github.com/oguna/jsmigemo/blob/master/migemo-dict

# vimで使いたい

vimでmigemoを使えないのか！！という声が聞こえてきました

安心してください、プラグインあります🤩

https://github.com/lambdalisue/vim-kensaku

denops作者のlambdalisueさんが作成されたプラグインです。vim-kensakuもdenopsでの実装です。

jsmigemoが採用されているのでオリジナルの[C/Migemo](https://www.kaoriya.net/software/cmigemo/)のインストールは不要です。
なんとありがたい！(denopsは必要です)

## 設定
lazy.nvimでの設定例です。

```lua file:lua/plugins/kensaku.lua
{
  'lambdalisue/kensaku.vim',
  {
    'lambdalisue/kensaku-search.vim',
    config = function()
      vim.api.nvim_set_keymap(
        'c',
        '<CR>',
        '<Plug>(kensaku-search-replace)<CR>',
        { noremap = true, silent = true }
      )
    end
  },
}
```
これだけでできます！

[![Image from Gyazo](https://i.gyazo.com/b5b53fb34c934213c2bb526e4b0bae5d.gif)](https://gyazo.com/b5b53fb34c934213c2bb526e4b0bae5d)


# おわり
日本人vimmerは100%migemoを使うべきだと思います！ 素晴らしきこの世界！
