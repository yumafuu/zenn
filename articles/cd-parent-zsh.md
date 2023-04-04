---
title: "[小ネタ] zshで最速で一個のディレクトリに移動する"
emoji: "😅"
type: "tech"
topics: ["zsh", "小ネタ"]
published: true
---

# やり方

zleを使います

zleについてはクラメソ様の記事がわかりやすいです

[ Macがzshになるなら、ZLEを習得するっきゃない！ ]( https://dev.classmethod.jp/articles/zsh-zle-introduction/ )

```zsh
# .zshrc に書いておく

zle -N cd_parent
bindkey "^h" cd_parent

cd_parent () {
  cd ..
  zle accept-line
}

```

CTRL+hだけで親ディレクトリに移動できる！！サイコー！！！！！！！
