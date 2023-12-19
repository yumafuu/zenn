---
title: "BCryptを理解する"
emoji: "🔐"
type: "tech"
topics: ["bcrypt", "deno"]
published: false
publication_name: "ispec_inc"
---

# はじめに

パスワードの保存のために良く使うBCryptをちゃんと理解してみようの会です

# BCryptとは

bcrypt（ビー・クリプト）はNiels ProvosとDavid Mazièresによって設計された1999年にUSENIXにて公開された、Blowfish暗号を基盤としたパスワードハッシュ化関数である[1]。レインボーテーブル攻撃に対抗するためにソルトを組み込んでいる以外に、bcryptは適応的な特性を備えている。計算能力が増えたとしてもブルートフォース攻撃に耐えられるように、繰り返し回数を増やして速度を落とせるようになっている。
