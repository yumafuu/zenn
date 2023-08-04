---
title: "URLを踏むだけでTerraformのbackendを作れるCFn"
emoji: "🐡"
type: "tech"
topics: ["terraform", "cloudformation", "AWS"]
published: true
publication_name: "ispec_inc"
---

# モチベーション

Terraformを使い始める時のS3 BucketとDynamoDBを毎回作るのがだるい。


# 解決策

CloudFormationのクイック作成リンクを使う。
はい、こちらひっじょうに便利です。ドキュメントは[こちら](https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/cfn-console-create-stacks-quick-create-links.html)

クイック作成リンクとはURLを踏むだけで、スタックを作成することができるというものです。

# 実装
下のようなyamlをS3に置いておいて、templateURLで指定するだけです
```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: Create terraform backend resources
Parameters:
  AppName:
    Type: String
    Description: App Name
    ConstraintDescription: Prefix of S3 Bucket And DynamoDB table

Resources:
  BackendBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    Properties:
      VersioningConfiguration:
        Status: Enabled
      BucketName: !Sub ${AppName}-terraform-state
      PublicAccessBlockConfiguration:
        BlockPublicAcls: True
        BlockPublicPolicy: True
        IgnorePublicAcls: True
        RestrictPublicBuckets: True

  BackendDynamoDbTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub ${AppName}-state-lock
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

そしたら以下のようにURLを作っておく、

https://ap-northeast-1.console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/stacks/create/review?templateURL=https://ispec-public.s3.ap-northeast-1.amazonaws.com/cfn-terraform-init-template.yaml&stackName=TerraformInit


作りたいアカウントでAWS consoleにログインしてる状態でURLを踏むと

[![Image from Gyazo](https://i.gyazo.com/c8ec4439fbf1e73f10a99e19158057b0.png)](https://gyazo.com/c8ec4439fbf1e73f10a99e19158057b0)


みたいなページが開いて、AppNameを入力するだけで、S3のバケットとDynamoDBが作れちゃう！
こりゃ便利！
