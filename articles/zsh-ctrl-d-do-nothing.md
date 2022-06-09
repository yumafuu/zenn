---
title: "zshでctrl+Dで何もしない"
emoji: "🐤"
type: "tech"
topics: ["zsh"]
published: true
---

# 以下で解決
```bash
function do_nothing(){}
zle -N do_nothing
bindkey "^D" do_nothing
setopt IGNORE_EOF
```


```bash
setopt IGNORE_EOF

```
だけだと

```bash
zsh: use 'exit' to exit.
```

って出てきて連打してるとexitしちゃう
