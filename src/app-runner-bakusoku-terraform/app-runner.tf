resource "aws_iam_role" "builder" {
  name = "${local.env}-apprunner-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com",
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
  ]
}

/* # 自前のVPC内のリソースのアクセスに必要 */
/* resource "aws_apprunner_vpc_connector" "main" { */
/*   vpc_connector_name = "${local.env}-${local.app}-apprunner-vpcconnector" */
/*   subnets            = module.vpc.private_subnets */
/*   security_groups    = [module.sg.security_group_id] */
/* } */

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

  /*   network_configuration { */
  /*     egress_configuration { */
  /*       egress_type       = "VPC" */
  /*       vpc_connector_arn = aws_apprunner_vpc_connector.main.arn */
  /*     } */
  /*   } */

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

output "service_url" {
  value = aws_apprunner_service.main.service_url
}
