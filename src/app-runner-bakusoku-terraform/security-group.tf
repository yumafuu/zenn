module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${local.env}.${local.app}.app-runner.sg"
  vpc_id = module.vpc.vpc_id

  egress_rules = ["all-all"]
}
