---
title: "ECRのTag Immutablityを突破するTips"
emoji: "🏋"
type: "tech"
topics: ["git", "aws", "ecr", "githubactions"]
published: true
publication_name: "ispec_inc"
---

# 困ったこと

同じコミットでもう一度デプロイしたいことが稀によくしばしばあります。

ですがイメージのtagにコミットハッシュを使っているときにはbuild & pushができなくなってしまいます。

下のようなActionsの設定があり

```yaml
jobs:
  build:
    name: Build Push Image
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v3
      - name: Build Image
        uses: ./.github/actions/build-push-image
        with:
          aws_role_arn: ${{ env.AWS_ROLE_ARN }}
          context: .
          dockerfile: ./api/docker/prod/Dockerfile
          ecr_repo: ${{ env.ECR_API_REPOSITORY }}
          tag: ${{ github.sha }} # ←ここ
```

同じcommit対して2度CIを起動した結果...

```
ERROR: tag invalid: The image tag '6736f93336b8244a55cae3a99106db7af15dda34' already exists in the 'my-awesome-image' repository and cannot be overwritten because the repository is immutable.
```

と怒られてしましました。

怒りのあまりlatest運用してやろうかと思いましたが、大人なので我慢しました。

# 解決策

1. そもそも同じタグでビルドできなくしてしまう

ビルド時刻をtagに含めることでtagの衝突を回避します

```yaml
jobs:
  build:
    name: Build Push Image
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v3
      - name: Build Image
        uses: ./.github/actions/build-push-image
        with:
          aws_role_arn: ${{ env.AWS_ROLE_ARN }}
          context: .
          dockerfile: ./api/docker/prod/Dockerfile
          ecr_repo: ${{ env.ECR_API_REPOSITORY }}
          tag: ${{ github.sha }}$(date +'%Y%m%d%H%M') # ←ここ
```

2. empty commitを使う

gitは変更してなくてもcommitできます

```bash
$ git commit --allow-empty
```
でできます

yamlが怖くていじれないという方には手っ取り早くておすすめです！


良きActions & ECR ライフを！
