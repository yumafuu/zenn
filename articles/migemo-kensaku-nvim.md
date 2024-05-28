---
title: "ローマ字で日本語検索する by migemo (with vim)"
emoji: "🔎"
type: "tech"
topics: ["migemo", "vim"]
published: false
publication_name: "ispec_inc"
---

# migemoとは?

Migemo はローマ字のまま日本語をインクリメンタル検索するため のツールです。
かな漢字変換をすることなく日本語のインクリメンタル検索を快適に行うことができます。

* 参照 [Migemo: ローマ字のまま日本語をインクリメンタル検索](http://0xcc.net/migemo/)

つまり、`検索`を`kensaku`という入力で検索できるようになります。

Emacsの機能としてリリースされているようです

https://github.com/emacs-jp/migemo


# vimで使いたい

vimでmigemoを使えないのか！！という声が聞こえてきました。

安心してください。プラグインがあります。
https://github.com/lambdalisue/vim-kensaku

denops作者のlambdalisueさんが作成されたプラグインです。vim-kensakuもdenopsでの実装です。

[jsmigemo](https://github.com/oguna/jsmigemo)が採用されているのでオリジナルの[C/Migemo](https://www.kaoriya.net/software/cmigemo/)のインストールは不要です。 なんとありがたい！

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
以上！！

# デモ


