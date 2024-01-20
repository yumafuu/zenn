---
title: "ecspressoで作るRDSの踏み台Fargate"
emoji: "💨"
type: "tech"
topics: ["ECS", "aws", "ecspresso", "fargate"]
published: true
publication_name: "ispec_inc"
---

# はじめに

ECS Fargate経由でプライベートSubnetにあるRDSにアクセスする方法をまとめます

使うツールは以下の通り
- 今回はこんな素晴らしいツールあったの？でお馴染み[ecspresso](https://github.com/kayac/ecspresso)
- [ECS Exec](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/ecs-exec.html)のポートフォワード機能

最終的にlocalhostに向けて以下のようにアクセスできるようになります

```bash
$ mysql -uuser -ppassword --host 127.0.0.1
```

CLI生まれCLI育ちの僕でもRDBはGUIクライアントを使いたいのでこの方法はとても有用だと思います(sshの場合はCLIでしかアクセスできない)


# ECS Execとは

実行中のコンテナに入ってコマンドを実行できるもの(docker execのECS版)です。
今回はその中のポートフォワード機能を使います


# 実装

## IAM Role

TaskRoleに以下のSSMのアクセス権限が必要ですので事前にアタッチしておきます

SSM AgentをバインドマウントしてSSMのセッションマネージャーとの通信するらしいです

[参考: デバッグ用にAmazon ECS Exec を使用](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/ecs-exec.html)


```json:policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowObjectAccess",
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
      ],
      "Resource": "*"
    }
  ]
}

```

Roleを作成するサンプルスクリプト

https://github.com/YumaFuu/ecspresso-portforward/blob/main/create-task-role.sh

実行ロールは特になんのアクションも許可する必要ありません

[amazon-ecs-exec-checker](https://github.com/aws-containers/amazon-ecs-exec-checker)でECS Execが使えるかの確認ができます


## ecspresso.yaml

いつものyamlです

```yaml:ecspresso.yaml
region: ap-northeast-1
cluster: your-cluster
service_definition: service-def.jsonnet
task_definition: task-def.jsonnet
```

## task-def.jsonnet

sleepだけすればいいので alpineからsleepだけコピってきた [yumafuu/sleepy](https://github.com/YumaFuu/docker-sleepy) を使います
嫌な方はsleepできるお好きなイメージに差し替えてください

```json:task-def.jsonnet
{
  family: "rdb-bastion",
  cpu: "256",
  memory: "512",
  executionRoleArn: "arn:aws:iam::000000000000:role/bastion-exec-role"
  taskRoleArn: "arn:aws:iam::000000000000:role/bastion-task-role"
  networkMode: "awsvpc",
  containerDefinitions: [
    {
      name: "bastion",
      image: "yumafuu/sleepy:latest",
      command: [
        "600", // 10分だけ起動する
      ],
    }
  ],
}

```

## service-def.jsonnet

サービスは使いませんが、ネットワークやECS Execの設定を記述します

```json:service-def.jsonnet

{
  launchType: "FARGATE",
  enableExecuteCommand: true, // ECS Execをするのに必要！
  networkConfiguration: {
    awsvpcConfiguration: {
      assignPublicIp: "DISABLED",
      securityGroups: [
        "sg-00000000000000000", // RDSへの通信を許可しておいてね
      ],
      subnets: [
        "subnet-00000000000000000"
      ],
    }
  },
}

```

## run.sh

実行のためのshellスクリプトです

```bash:run.sh
AWS_PROFILE=your-profile
ECSPRESSO_CONFIG=ecspresso.yaml
CLUSTER=your-cluster
FAMILY=rdb-bastion
RDB_HOST=rdb-cluster.cluster-xxxxxxxxx.ap-northeast-1.rds.amazonaws.com

# --no-waitで起動することでコンテナが起動したら次の処理に進める
ecspresso run --config $ECSPRESSO_CONFIG --no-wait

# 最新のタスクのIDを取得
id=$(
    AWS_PROFILE=your-profile aws ecs list-tasks \
    --cluster $CLUSTER --family $FAMILY \
    --query taskArns[0] --output text | cut -d'/' -f3 \
)

# ここでコンテナがRUNNINGになるまで待つ
echo Wait until task running..
aws ecs wait tasks-running \
  --cluster $CLUSTER \
  --tasks $id

# ポートフォワードする
ecspresso exec \
  --port-forward \
  --port 3306 \
  --local-port 3306 \
  --config $ECSPRESSO_CONFIG \
  --host $RDB_HOST \
  --id $id
```


bashで実行したら20秒くらいでTaskが起動します

```bash
$ bash ./run.sh
# ....

Waiting for connections...
```
が出たらlocalhostにアクセスできるようになっています！

```bash
$ mysql -uuser -ppassword --host 127.0.0.1
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 247708
Server version: 8.0.28 Source distribution

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

admin@172.16.3.11 [(none)] 02:35 pm>
```

ちなみにcommandで指定した秒数でTaskが死ぬので、適宜変更が必要です

# ソースコード

色々にまとめておきましたので詳しくみたい方はこちらから！

https://github.com/YumaFuu/ecspresso-portforward

# おわりに

ecspresso本当に素晴らしい、、🤙

他にもecspressoの運用を以下で紹介してますので是非見てみてください！

https://zenn.dev/ispec_inc/articles/ecspresso-lt

