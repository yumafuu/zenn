---
title: "ターミナルでディレクトリを駆け巡る(fzf, tmux)"
emoji: "🏎️"
type: "tech"
topics: ["zsh", "tmux", "fzf"]
published: true
---

# モチベーション

ディレクトリを移動するときのtab連打が辛い

## 環境

zsh
fd # https://github.com/sharkdp/fd
fzf # https://github.com/junegunn/fzf
tmux
tmux-fzf # https://github.com/sainnhe/tmux-fzf

## ディレクトリ編

### カレントディレクトリ以下に移動
```bash
# .zshrc

function cd_target(){
  d=$( \
    fd --type d -H \
    -E .git \
    -E node_modules \
    -E .terragrunt-cache \
    | fzf )

  if [[ $d = "" ]]; then
    return
  fi

  cd $d
}

zle -N cd_target
bindkey "^k" cd_target
```

ctrl+kで発動

![](https://storage.googleapis.com/zenn-user-upload/7f147c574a7e-20220221.gif)


### rootディレクトリに移動
```bash
# .zshrc

# 最寄りの.gitがあるディレクトリをrootとする
function cdr() {
  export TMP_CDR_DIR=$(pwd)

  while [[ $TMP_CDR_DIR != "/" ]]
  do
    if [ -e "$TMP_CDR_DIR/.git" ];then
      echo $TMP_CDR_DIR
      cd $TMP_CDR_DIR
      break
    else
      export TMP_CDR_DIR=$( dirname $TMP_CDR_DIR )
    fi
  done
  unset TMP_CDR_DIR
}

```

![](https://storage.googleapis.com/zenn-user-upload/b70eecfa602a-20220221.gif)

## tmux編

### session移動
```bash
# ~/.tmux/bin/tmux-fzf-session
# 確かこれが必要　https://github.com/sainnhe/tmux-fzf

#!/bin/bash

if [ -n "$TMUX" ]; then
  session="$(tmux ls |
    cut -d : -f 1 |
    fzf
  )"

  if [ -n "$session" ]; then
    tmux switch -t $session
  fi
fi

# ~/.tmux.conf
bind w popup -E "$HOME/.tmux/bin/tmux-fzf-session"
```

![](https://storage.googleapis.com/zenn-user-upload/bae08b4546b9-20220221.gif)

人生のキーストロークが半分くらいになった
