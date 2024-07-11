---
title: FargateのログをfirelensでDatadogに送る
emoji: 🔎
type: tech
topics: [aws, ECS, Fargate, firelens, datadog]
published: false
publication_name: ispec_inc
---

# やりたいこと

firelensを使ってECSのFargateのコンテナのログをDatadogに送る方法を紹介します！

firelensくんが最強で思ってるより簡単にできるので、ぜひ試してみてください！

# Firelensとは

ログルーターであるFluentBit をマネージドで提供してくれるサービスです。
ECSのタスク定義でログをルーティングしたいコンテナのサイドカーにfirelensのコンテナを定義して、 logConfigurationのlogDriverに`awsfirelens`を指定することで、ログをfirelensに送ることができます。

*参考*
- [fluentbit](https://fluentbit.io/)
- [詳解 FireLens – Amazon ECS タスクで高度なログルーティングを実現する機能を深く知る | Amazon Web Services ブログ](https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/)



# 実装

## 1. APIキーの取得

https://ap1.datadoghq.com/organization-settings/api-keys で DataDogのAPIキーを取得して,SSM parameter Storeに保存しておきます。

```bash
$ aws ssm put-parameter \
    --name "/prod/DATADOG_API_KEY" \
    --value "${YOUR_API_KEY}" \
    --type SecureString
```

## ECSのタスク定義を作成

Datadogのドキュメントは以下のようになっています。
[![Image from Gyazo](https://i.gyazo.com/86339d30adaf9495c227f3cf33052f02.png)](https://gyazo.com/86339d30adaf9495c227f3cf33052f02)

ポイントとして、`apikey`を直接記述するのはセキュリティ的に問題があるので、SSM parameter Storeから取得するようにします。
secretOptionsでoptionの値をSSM parameter storeかsecret managerから取得することができます。
ARNかkeyの名前を指定することで取得することができます。

*参考*
- [Amazon ECS ログ記録設定のシークレットを取得する - Amazon Elastic Container Service](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/secrets-logconfig.html)


```json5
{
  // ...
  containerDefinitions: [
    {
      name: "main-container",
      image: "ubuntu:latest",
      logConfiguration: {
        logDriver: 'awsfirelens',
        options: {
          Name: 'datadog',
          Host: 'http-intake.logs.ap1.datadoghq.com', // Datadogサイトに合わせる(後述)
          TLS: 'on',
          dd_service: 'your-service',
          dd_source: 'your-source',
          dd_tags: 'env:prod',
          provider: 'ecs',
        },
        secretOptions: [{
          name: "apikey",
          valueFrom: "/prod/DATADOG_API_KEY",
        }]
      },
    },
    {
      name: "log-router",
      image: "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.32.2.20240627", // 2024/07/09 時点で最新
      essential: true,
      firelensConfiguration: {
        type: "fluentbit",
        options: {
          "enable-ecs-log-metadata": "true"
        }
      },
      // log-routerのログをcloud watchに出力する場合 *1
      // logConfiguration: {
      //   logDriver: "awslogs",
      //   options: {
      //     "awslogs-group": "/ecs/your-service",
      //     "awslogs-region": "ap-northeast-1",
      //     "awslogs-stream-prefix": "ecs"
      //   }
      // },
      memoryReservation: 50,
    },
  ],
}
```

firelensのイメージはこちらで公開されております
- [aws/aws-for-fluent-bit: The source of the amazon/aws-for-fluent-bit container image](https://github.com/aws/aws-for-fluent-bit)

## ハマったところ

上記を設定する際になかなかアプリケーションのログがDatadogに送られないことがありました。
`log-router`のコンテナのログをcloud watchに出力するように設定して確認してみると、以下のエラーが出力されていました。 *1

(ググりまくったけど全然できこなかった...)

```
[error] [output:datadog:datadog.1] http://http-intake.logs.datadoghq.com:80 HTTP status=403
```

認証まわりで怒られいたので,APIキーが正しく設定されていないのではと思い、secretOptionsをやめてみたり、SSM parameter Storeの値を確認したりしてみましたが、問題はありませんでした。

結論、送信先のHostが間違っていました。
デフォルトでは`US1`のホストである`http-intake.logs.datadoghq.com`が設定されているようです。

ですが、Datadogサイトに合わせて、送信先のホストを変更する必要があるようです。
- [Datadogのドキュメント](https://docs.datadoghq.com/ja/integrations/fluentbit/?site=ap1)

ホスト一覧は以下の通りです。

[![Image from Gyazo](https://i.gyazo.com/98d68825e882ecd20c248882691563e7.png)](https://gyazo.com/98d68825e882ecd20c248882691563e7)
- [Datadog サイトの概要](https://docs.datadoghq.com/ja/getting_started/site/#datadog-%E3%82%B5%E3%82%A4%E3%83%88%E3%81%AB%E3%82%A2%E3%82%AF%E3%82%BB%E3%82%B9%E3%81%99%E3%82%8B)

自分は`ap1`でアカウントを作成していたので `http-intake.logs.ap1.datadoghq.com`に変更したところ、ログがDatadogに送られるようになりました。


# おわりに

シンプルですが、文献が少ないのでハマりました

これからもオブザーバビリティを高めてオブオブしていきたいです！
