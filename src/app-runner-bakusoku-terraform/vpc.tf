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
