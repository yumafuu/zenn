---
title: Datadog Error TrackingのCustom Groupingで運用負荷を軽減
emoji: 🌭
type: tech
publication_name: knowledgework
topics: [datadog, observability]
published: false
---

<!-- 概要 -->

お久しぶりです、yumaです

今日はDatadogの[Error Tracking](https://www.datadoghq.com/ja/product/error-tracking/)でアラート数を削減し、各チームが自律的にDevOpsできる環境を構築した事例を紹介します🚀

この記事は、「KNOWLEDGE WORK Blog Sprint」第3日目の記事です

## 背景・課題

Datadog Error Trackingには、スタックやtraceなどの情報を元に自動でIssueをまとめる機能があります。
しかし、同じエラーメッセージでもtraceやコンテキストが異なると別Issueとして扱われ、ノイズが増えがちです。

https://docs.datadoghq.com/real_user_monitoring/error_tracking/explorer/

ナレッジワークでは、`context canceled `を含むエラーがまとまらず、毎週数十件の同様アラートが発生していました。
Datadog上で個別にIgnoreしても、微妙に異なるtraceのため新しいIssueとして再出現して、いたちごっこの状態になっていました。
結果、週次の非同期トリアージ会で毎回ignore作業が発生し、運用負荷になっていました。


## 対応

### 実装

Datadog Error TrackingのCustom Groupingの機能を使って、別物と判定されてしまう同義のエラーを一つのErrorとしてまとめられるようにします。

https://docs.datadoghq.com/error_tracking/error_grouping/?tab=android#custom-grouping


Datadog Logsに送信されるエラーに以下のように`error.fingerprint`というプロパティを付与するだけで完了です。

```json5
{
    // other properties...
    "error": {
        "fingerprint": "{FingerprintName}"
    }
}
```
fingerprintを設定してもサービスを超えてまとまることはないので、適切にserviceを設定しておくことで過剰にまとまりすぎることを抑制できます。


また、Google Cloudでは`error.fingerprint`は特別な意味を持たないため、まず`labels.datadog_fingerprint`として送信し、Datadog側でリマップする方式を採用しました。バックエンドサーバーからは以下のようなjsonを送信します。
```json5
{
    // other properties...
    "message": "context canceled: some error message",
    "labels": {
        "datadog_fingerprint": "{FingerprintName}"
    }
}
```

そしてDatadog LogsのPipelineで`labels.datadog_fingerprint`を`error.fingerprint`にリマップしたら完了です。

以下がterraformでの実装例です。

```hcl
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

https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/logs_custom_pipeline

### セルフサービス化
ナレッジワークでは複数プロダクトの開発チームが存在しています。

以前はDatadogのデフォルト設定をそのまま使用していましたが、各チームがオーナーシップを持って自律的にDevOpsできるよう、設定を各チームが所有するコードベースから行えるインターフェースを用意しました。


```go
// fingerprintを設定する条件とfingerprint名を指定できる
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

結果的に画像のように、別のエラーが一つのエラーとしてまとまっているのが確認できました。

Before
![](/images/datadog-error-fingerprint/image-before.png)

After
![](/images/datadog-error-fingerprint/image-after.png)


この対応により、毎週数十件発生していた`context canceled`エラーが1つに集約され、実質的にアラート件数が0になりました

週次のエラートリアージ会でも、これらのエラーをignoreする作業が不要になり、運用工数を大幅に削減できました。また各チームが自律的にError Tracking管理できる環境も構築できました👏

Datadog Error Trackingのfingerprintを使ったCustom Groupingは文献が少なかったので、ぜひ参考にしてみてください！

KNOWLEDGE WORK Blog Sprint、明日9/4の執筆者はQAエンジニアのtettanです。
お楽しみに！
