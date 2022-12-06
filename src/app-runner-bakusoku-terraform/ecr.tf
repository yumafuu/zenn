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
  repository = aws_ecr_repository.main.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire images other than lastest 30 images.",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}
