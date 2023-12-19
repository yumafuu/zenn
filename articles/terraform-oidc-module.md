---
title: "AWSのOIDC with GithubのTerraform module作ってみた"
emoji: "🤙"
type: "tech"
topics: ["terraform", "AWS", "oidc"]
published: true
publication_name: "ispec_inc"
---

# モチベーション

Terraformで毎度OIDCの設定をするのに同じコードを作っていたのでTerraformのmoduleとして公開してしまえ！っていうやつです

Terraformのmodule設計はめちゃくちゃ気をつけないとあとで地獄を見るのですが、この粒度であれば大丈夫と判断しました👀


作ったものはこちら

https://github.com/ispec-inc/aws-oidc-github-terraform

OIDC providerと対応するIAM Role, IAM policyが作られるシンプルなものです

# 実装

パブリックなGitHubリポジトリにコードを置いておくだけでmoduleとして使えちゃうので、今回はこちらを採用

## コード

特別なことは何一つしていないけどこんな感じ
(複数のレポジトリに対応していないけど、単一で事足りているからまぁいいか)

```hcl
data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = [aws_iam_openid_connect_provider.this.arn]
      }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.org}/${var.repo}:ref:${var.ref_prefix}",
          ]
        }
      }
    }]
  })
}

resource "aws_iam_policy" "oidc_policy" {
  name   = var.policy_name
  policy = var.policy_json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.oidc_policy.arn
  role       = aws_iam_role.this.name
}
```

## ドキュメント

公開するにあたって必要なのがわかりやすいREADMEと動くexamplesだと思います

### README

terraform-docsというterraform moduleのdocument生成ツールがあります

https://github.com/terraform-docs/terraform-docs/

必要なproviderやterraformのバージョン、inputとoutputがマークダウンで出力できます。

moduleのREADMEとしてはこれで十分でしょう！

僕はわかりやすさのためにUSAGEを加えました

### examples

これも大事。
自分がOSSを使う時はめちゃくちゃexamplesを見たいので、追加した

# 終わりに

思っているよりもめちゃくちゃ簡単に公開できました！
定期的なアプデとかCI整備とか色々ちゃんとやって行きたいです

たくさん作りたくなっちゃいますが、地獄を見ないように設計には十分気をつけよう...✌️
