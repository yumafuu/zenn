---
title: "ecsressoで作るFargateポートフォワード踏み台"
emoji: "🥷"
type: "tech"
topics: ["ECS", "ecsresso", "fargate"]
published: false
publication_name: "ispec_inc"
---

# 踏み台サーバーがだるい

PrivateなSubnetにあるAuroraにアクセスしたくなることは稀に頻繁にときどきよくあることだと思います。

以前までの弊社では踏み台用のEC2を同じSubnetに立てておいてSSMのsession機能を使ってsshしていました。

まぁスマートじゃないし、慣れないCLIでのDB操作を強いられる運用に嫌気がさしていたので、ECSに乗せてポートフォワードを行い、手元のGUIクライアントから操作できるようにしてしまおうというものです！


# 実装

## ecsressoを使う

簡単のためにecsresso pluginなどは省略しています

詳しい運用は以下で紹介してます

https://zenn.dev/ispec_inc/articles/ecspresso-lt


```yaml
# bastion/ecspresso.yaml
region: ap-northeast-1
cluster: my-super-cluster
service: dev-bastion
service_definition: service-def.jsonnet
task_definition: task-def.jsonnet
timeout: "20m0s"
```

```jsonnet
// bastion/task-def.jsonnet

{
  family: "rdb-bastion",
  cpu: "256",
  memory: "512",
  executionRoleArn: "arn:aws:iam::000000000000:role/bastion-exec-role"
  taskRoleArn: "arn:aws:iam::000000000000:role/bastion-task-role"
  requiresCompatibilities: ["FARGATE"],
  networkMode: "awsvpc",
  containerDefinitions: [
    {
      name: "bastion",
      image: "alpine:latest",
      command: [
        "sleep", "600", # 10分だけ起動する
      ],
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/aws/ecs/cluster/dev/pcpk-api/ecs',
          'awslogs-region': 'ap-northeast-1',
          'awslogs-stream-prefix': 'bastion-',
        },
      },
    }
  ],
}

```


```jsonnet
// bastion/service-def.jsonnet

{
  launchType: "FARGATE",
  enableExecuteCommand: true, // ポートフォワードするのに必要
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


```bash
AWS_PROFILE=your-profile
ECSPRESSO_CONFIG=bastion/ecspresso.yaml
CLUSTER=your-cluster
FAMILY=rdb-bastion
RDB_HOST=rdb-cluster.cluster-xxxxxxxxx.ap-northeast-1.rds.amazonaws.com

ecspresso run --config $ECSPRESSO_CONFIG --no-wait

id=$(
AWS_PROFILE=your-profile aws ecs list-tasks \
    --cluster $CLUSTER --family $FAMILY \
    --query taskArns[0] --output text | cut -d'/' -f3 \
)

echo Wait until task running..
aws ecs wait tasks-running \
  --cluster $CLUSTER \
  --tasks $id

ecspresso exec \
  --port-forward \
  --port 3306 \
  --local-port 3306 \
  --config $ECSPRESSO_CONFIG \
  --host $RDB_HOST \
  --id $id
```


