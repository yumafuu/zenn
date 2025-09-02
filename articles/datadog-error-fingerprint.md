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

今日はDatadogの[Error Tracking](https://www.datadoghq.com/ja/product/error-tracking/)でアラート数を削減し、各チームが自律的にDevOpsできる環境を構築した事例を紹介します。


## 課題

Datadog Error Trackingではtrace情報をみて自動でissueをまとめてくれる機能があります。

しかし同じエラーメッセージでもtrace情報が違うと別のエラーとして区別されてしまいます。

ナレッジーワークでは`context canceled`という文言を含むエラーが一つにまとまらず、Datadog上でignoreの対応をしてもまた別の同じメッセージが上がってきており、いたちごっこなってしまっていました。


## 対応

### 実装

Datadog Error TrackingのCustom Groupingの機能を使って、別物と判定されてしまうエラーを一つのErrorとしてまとめられるようにします。

https://docs.datadoghq.com/error_tracking/error_grouping/?tab=android#custom-grouping

Datadog Logsに送信されるエラーに以下のようにerror.fingerprintというプロパティを付与するだけで完了です。

```json
{
    // ...
    "error": {
        "fingerprint": "{FingerprintName}"
    }
}
```

Google Cloudでは`error.fingerprint`は特別な意味を持たないため、まず`labels.datadog_fingerprint`として送信し、Datadog側でリマップする方式を採用しました。バックエンドサーバーからは以下のようなjsonを送信します。
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

以前はDatadogのデフォルト設定をそのまま使用していましたが、各チームがオーナーシップを持って自律的にDevOpsできるよう、設定を各チームが所有するコードベースから行えるインターフェースを用意しました。

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

![](/images/datadog-error-fingerprint/image.png)


この対応により、同じメッセージのエラーを個別にignoreする必要がなくなり、アラート数が大幅に削減されました。また各チームが自律的にError Trackingを管理できる環境を構築できました。

KNOWLEDGE WORK Blog Sprint、明日9/4の執筆者はQAエンジニアのtettanです。
お楽しみに！
