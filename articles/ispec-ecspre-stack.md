---
title: "ECSのパワーを最大限引き出すエスプレスタック"
emoji: "☕️"
type: "tech"
topics: ["aws", "ecs", "espresso", "ecschedule"]
published: false
publication_name: "ispec_inc"
---

# エスプレスタックとは

みんな大好き[Tori Haraさん](https://twitter.com/toricls)のこちらのツイート

https://twitter.com/toricls/status/1444858805532037133

を勝手に拝借して自分もエスプレスタックと呼んでいます。

## ecspresso
ecspressoはfujiwaraさん作のECSのデプロイツールです。

service-def.yamlとtask-def.yamlを書いておいてデプロイを簡単にするためのものです。

## ecschedule
ecscheduleは、ECSのScheduled Tasksを管理するためのツールです。
クラスターやタスク、cronの設定を書いておくことで設定できるツールです。

どちらもGoで書かれていて、バイナリが配布されているので、ローカル環境やCI環境を意識せずに使うことができます(Go最高)

# 課題
espressoはjsonnetを設定ファイルとして利用できますが、ecscheduleは無理でした。

https://github.com/Songmu/ecschedule/releases/tag/v0.8.0
ですので弊社の[ 丸山くん ](https://github.com/mrymam)がPRをあげてくれてecscheduleでも使えるようにしてくれました！

# 実装
特別なことはしてないけど、雰囲気を紹介します。

staging環境とproduction環境を作る想定です。
```

```


