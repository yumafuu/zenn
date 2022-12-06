---
title: "TerraformでAppRunnerを爆速で作ってみる"
emoji: "💨"
type: "tech"
topics: ["aws", "apprunner", "terraform"]
published: false
---

# はじめに

こんにちは。App Runner大好きyamlエンジニアのyuma ishikawaです！
今回はAWSの個人的大注目サービスのAppRunnerをサクッと動かすためのterraformの例を紹介します。

AWSでコンテナを動かしたいならECSかEKSだと思いますが、ECSはALBとかECSのServiceとかTaskとかよくわからん...とか、Kubernetesなんて恐ろしくて手が出せない...とか敷居が高いですよね分かります。

アプリ開発をしたいけどインフラの知識がない...だったり、サーバーのこと考えないでゴリゴリ機能開発したい!!だったりといったケースに持ってこいのサービスだと思っています。

各リソースについて軽く紹介しながらTerraformの運用Tipsも織り込んでおりますので、AWSとTerraformの初心者の方やTerraformerの方々にぜひ読んでみて欲しいです!

# 実装

早速実装に入っていきます！

AppRunnerにデプロイ方法は複数用意されていますが、今回はECRのイメージを使う方法を使っていきます。

今回作るのは、
- VPC
- Secury Group
- ECR
- AppRunner

の大きく4つです。

AppRunnerはAWSのマネージドのVPCにサービスが作成されます。(マネコンからは見えない)
なのですが、VPC Connectorというものを使えば自分たちで作ったVPCのprivateなリソース(Auroraとか)にアクセスすることができます。今回はそれも作っていきます。

実際のコードは[ここ](https://github.com/YumaFuu/zenn)にありますので、詳しく見たい方は見てみてください。

## ディレクトリ構成

今回はシンプルにリソースごとにファイルを分けていきます

```bash
.
├── backend-cfn.yaml # terraformで使うためのS3とDynamodbをcloudformationで作成するためのファイルです
├── app-runner.tf
├── ecr.tf
├── locals.tf # 各ファイルから参照する値をまとめています
├── config.tf # providerやbackendの設定をします
├── security-group.tf
└── vpc.tf
```

## バックエンドの作成・設定

Terraformはリソースの状態をtfstateというファイルに記述して管理します。
独り占めしちゃうとよくないのでS3に置いて管理するのが一般的です。(機密情報が含まれるのでGit管理はNG)

詳しくは[こちら](https://developer.hashicorp.com/terraform/language/state)

こんな感じで実行するだけでできちゃいます。便利ー！
```bash
$  aws cloudformation deploy \
  --stack-name awesomeapp-prod-terraform-backend \
  --template-file backend-cfn.yaml \
  --parameter-overrides Env=prod App=awesomeapp

```

<details>
<summary>backend-cfn.yaml</summary>

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: |
  Create terraform backend resources
Parameters:
  App:
    Type: String
  Env:
    Type: String
    Description: Select the environment to deploy
    ConstraintDescription: Must be any of the available options

Resources:
  BackendBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    Properties:
      VersioningConfiguration:
        Status: Enabled
      BucketName: !Sub ${App}-${Env}-bucket
      PublicAccessBlockConfiguration:
        BlockPublicAcls: True
        BlockPublicPolicy: True
        IgnorePublicAcls: True
        RestrictPublicBuckets: True

  BackendDynamoDbTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub ${App}-${Env}-dynamodb
      BillingMode: PROVISIONED
      ProvisionedThroughput:
        ReadCapacityUnits: 1
        WriteCapacityUnits: 1
      KeySchema:
        - AttributeName: LockID
          KeyType: HASH
      AttributeDefinitions:
        - AttributeName: LockID
          AttributeType: S

Outputs:
  BackendBucket:
    Value: !Ref BackendBucket
  BackendDynamoDbTable:
    Value: !Ref BackendDynamoDbTable

```
</details>


次に、Terraformの設定をしていきます。

config.tfに以下を突っ込みます。`resource "aws_xxxxxxxxxx" ` を使えるようにするための設定とさっき作ったBackendの設定です。


```hcl
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Env = "prod"
      App = "awesome-app"
    }
  }
}

terraform {
  required_version = "= 1.3.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29"
    }
  }

  backend "s3" {
    bucket         = "awesome-prod-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "awesome-prod-dynamodb"
    encrypt        = true
  }
}

```

## 各リソースの説明

一個ずつサクッとみていきます!

長いとこは省略しています

### VPC

[ VPC ](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/what-is-amazon-vpc.html)とはAWS上の仮想ネットワークです。この上に色々乗っかっていきます。

[terraformの公式module](https://registry.terraform.io/modules/terraform-aws-modules)が便利なのでガンガン使っていきましょう!

Aurora作る想定でdatabase_subnetsを作ってます。

vpc.tf

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${local.env}-${local.app}-vpc"

  cidr = "172.16.0.0/16"
  azs  = ["${local.region}a", "${local.region}c", "${local.region}d"]

  public_subnets   = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnets  = ["172.16.3.0/24", "172.16.4.0/24"]
  database_subnets = ["172.16.5.0/24", "172.16.6.0/24"]

  public_subnet_suffix   = "${local.env}-${local.app}-public"
  private_subnet_suffix  = "${local.env}-${local.app}-private"
  database_subnet_suffix = "${local.env}.${local.app}-database"
}

```

### SecurtyGroup

[ SecuryGroup ](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/VPC_SecurityGroups.html)とはVPC内のリソースで、リソース間のトラフィックを制御することができます。

こちらもterraformの公式moduleがあるので使っていきます。

```hcl

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${local.env}.${local.app}.app-runner.sg"
  vpc_id = module.vpc.vpc_id

  egress_rules = ["all-all"]
}

```

</details>

### ECR

[ECR](https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/what-is-ecr.html)とは、Dockerイメージを置いておくための箱です。AppRunnerで動かしたいイメージをここに置いておいて、後から参照しにきます。

ecr.tf

```terraform
resource "aws_ecr_repository" "main" {
  name = "${local.env}-${local.app}"

  # AppRunnerではlatestタグに新しいイメージをpushしたら自動的にデプロイされる
  # そのためアンチパターンだけどlatest運用
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# AppRunnerを起動するために仮のイメージを置いておく
resource "null_resource" "tmp_image" {
  provisioner "local-exec" {
    command = <<BASH
    echo $REPOSITORY_URL
      aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

      # 実際のアプリケーションのイメージをビルドしても良い
      docker pull nginx:latest --platform=amd64
      docker tag nginx:latest $REPOSITORY_URL":latest"
      docker push $REPOSITORY_URL":latest"
    BASH

    environment = {
      AWS_REGION     = local.region
      AWS_ACCOUNT_ID = local.aws_account_id
      REPOSITORY_URL = aws_ecr_repository.main.repository_url
    }
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
# ...
}
```

### AppRunner

今回のメインです！

[AppRunner](https://aws.amazon.com/jp/apprunner/)はフルフルマネージドのコンテナアプリケーションサービスです！
インフラストラクチャやコンテナの経験がなくても、コンテナ化されたウェブアプリケーションや API サービスを構築、デプロイ、実行できちゃうらしいです。


```
resource "aws_iam_role" "builder" {
  # ...
}

# 自前のVPC内のリソースのアクセスに必要
resource "aws_apprunner_vpc_connector" "main" {
  vpc_connector_name = "${local.env}-${local.app}-apprunner-vpcconnector"
  subnets            = module.vpc.private_subnets
  security_groups    = [module.sg.security_group_id]
}

resource "aws_apprunner_service" "main" {
  service_name = "${local.env}-${local.app}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.builder.arn
    }

    image_repository {
      image_configuration {
        port                          = local.port
        runtime_environment_variables = {}
      }
      image_identifier      = "${aws_ecr_repository.main.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.main.arn
    }
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  lifecycle {
    ignore_changes = [
      # 機密情報はコンソールから修正する運用を想定
      source_configuration[0].image_repository[0].image_configuration[0].runtime_environment_variables
    ]
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "${local.app}-autoscaling"

  max_concurrency = 50
  max_size        = 10
  min_size        = 1
}

# カスタムドメインを使う場合はこちら
# CNAMEが発行されるのでroute53とかに突っ込む
resource "aws_apprunner_custom_domain_association" "main" {
  service_arn          = aws_apprunner_service.main.arn
  domain_name          = local.domain
  enable_www_subdomain = false
}

# 確認用
output "service_url" {
  value = aws_apprunner_service.main.service_url
}

```


## Applyしていく！

実際にapplyしてみます!

```
$ terrafom init # moduleを引っ張ってくる
$ terrafom apply
```

しばらくしたら
```
Outputs:

service_url = "xxxxxxxxxx.ap-northeast-1.awsapprunner.com"
```
みたいな感じでservice_urlが出てくるので、アクセスしてみると...


[![Image from Gyazo](https://i.gyazo.com/e655e39b4174d8d62037c7e0915c8245.png)](https://gyazo.com/e655e39b4174d8d62037c7e0915c8245)


おぉ〜、アクセスできました！

# 終わりに

AppRunner爆速で作る with Terraformでやってみました。

IaCのメリットとして一度作ってしまえばテンプレートとして使いまわせるので、ちょっとコンテナ動かしたいなみたいな時に非常に楽に運用できますので、是非お試しください！

それでは、快適なAppRunnerライフを🚀
