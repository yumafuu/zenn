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

