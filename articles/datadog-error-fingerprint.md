---
title: Datadog Error TrackingのCustom Groupingで運用負荷を軽減
emoji: 🌭
type: tech
publication_name: knowledgework
topics: [datadog, observability]
published: false
---

<!-- 概要 -->

お久しぶりです、yumaです！

この記事は、「KNOWLEDGE WORK Blog Sprint」第3日目の記事になります。

今日はDatadogの[Error Tracking](https://www.datadoghq.com/ja/product/error-tracking/)でError Trackingの体験向上とセルフサービス推進をした事例を紹介します。


## 第2章 <!-- 課題 -->

Datadog Error Trackingではtrace情報をみて自動でissueをまとめてくれる機能があります。

しかし同じエラーメッセージでもでもtrace情報が違うと別のエラーとして区別されてしまいます。

ナレッジーワークでは`context canceled`という文言を含むエラーが一つにまとまらず、Datadog上でignoreの対応をしてもまた別の同じメッセージが上がってきており、いたちごっごになってしまっていました。


## 第2章 <!-- 対応 -->

Datadog Error TrackingのCustom Groupingの機能を使って、別物と判定されてしまうエラーを一つのErrorとしてまとめられるようにします。

https://docs.datadoghq.com/error_tracking/error_grouping/?tab=android#custom-grouping

Datadog Logsに送信されるエラーに以下のようerror.fingerprintというプロパティを付与するだけで完了です。

```json
{
    // ...
    "error": {
        "fingerprint": "{FingerprintName}"
    }
}
```

jsonのプロパティごとに責務を分離できるようにバックエンドサーバーからは以下のようなjsonを吐き出すようにしておきます。
```json
{
    // ...
    "labels": {
        "datadog_fingerprint": "{FingerprintName}"
    }
}
```

そしてDatadog LogsのPipelineでlabels.datadog_fingerprintをerror.fingerprintにリマップしたら完了です。

以下がterraformでの実装例です。

```terraform
resource "datadog_logs_custom_pipeline" "error_tracking_remap" {
  // ...
  processor {
    attribute_remapper {
      name       = "error.fingerprint-remapper"
      is_enabled = true
      sources = [
        "labels.datadog_fingerprint",
      ]
      source_type          = "attribute"
      target               = "error.fingerprint"
      target_type          = "attribute"
      preserve_source      = true
      override_on_conflict = false
    }
  }
}
```


### セルフサービス化
ナレッジワークでは複数プロダクトの開発チームが存在しています。

各チームがDatadog Error Trackingをセルフサービスとして扱えるように、設定を各チームが所有するコードベースから設定できるようなインターフェースを用意しました。

```go
log.AddHook(cloudlogging.DatadogFingerprintHook(
    cloudlogging.FingerprintRule{
        Name: "teamA-custom_error",
        Condition: func(event *zerolog.Event, msg string) bool {
            return strings.Contains(msg, "teamA")
        },
    },
))
```


## まとめ

画像のように、別のエラーが一つのエラーとしてまとまっているのが確認できました。

![](/images/datadog-error-fringerprint/image.png)


簡単な対応で運用者の負担を大きく減らし、オーナーシップを発揮しやすい環境を作ることができました。

KNOWLEDGE WORK Blog Sprint、明日9/4の執筆者はQAエンジニアのtettanです。
お楽しみに！
