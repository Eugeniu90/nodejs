# Configure VPC, subnets, etc
module "vpc" {
  source = "../../modules/vpc"

  name = "${terraform.workspace}-poc-vpc"
  cidr = "${var.cidr_prefix}.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs = local.availability_zones
  private_subnets = slice(
    [
      "${var.cidr_prefix}.1.0/24",
      "${var.cidr_prefix}.2.0/24",
      "${var.cidr_prefix}.3.0/24",
    ],
    0,
    length(local.availability_zones),
  )

  public_subnets = slice(
    [
      "${var.cidr_prefix}.101.0/24",
      "${var.cidr_prefix}.102.0/24",
      "${var.cidr_prefix}.103.0/24",
    ],
    0,
    length(local.availability_zones),
  )
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = false

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # We create our own policies and log group so we can better control naming and access patterns
  enable_flow_log                  = true
  flow_log_destination_type        = "cloud-watch-logs"
  flow_log_destination_arn         = aws_cloudwatch_log_group.vpc_flowlogs.arn
  flow_log_cloudwatch_iam_role_arn = aws_iam_role.vpc_flowlogs.arn

  vpc_flow_log_tags = {
    Name = "${terraform.workspace}-vpc-flow-logs"
  }

  tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      }

      public_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                      = "1"
      }

      private_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"             = "1"
      }
}

# Resources for flow logs

resource "aws_cloudwatch_log_group" "vpc_flowlogs" {
  name = "${terraform.workspace}-vpc-flow-logs-log-group"
}

data "template_file" "vpc_flowlogs" {
  template = file("${path.module}/iam_policies/cloudwatch_vpc_flowlogs_policy.json.tpl")
  vars = {
    account_id = local.aws_account
    env_id     = terraform.workspace
    region     = var.aws_region
    vpc_id     = module.vpc.vpc_id
  }
}

resource "aws_iam_role" "vpc_flowlogs" {
  name               = "${terraform.workspace}-cloudwatch-flowlogs"
  assume_role_policy = file("${path.module}/iam_policies/cloudwatch_vpc_flowlogs_assume_role_policy.json")
}

resource "aws_iam_policy" "vpc_flowlogs" {
  name   = "${terraform.workspace}-cloudwatch-flowlogs"
  policy = data.template_file.vpc_flowlogs.rendered
}

resource "aws_iam_policy_attachment" "vpc_flowlogs" {
  name       = "iam-role-attachment-${terraform.workspace}-cw-flowlogs"
  roles      = [aws_iam_role.vpc_flowlogs.name]
  policy_arn = aws_iam_policy.vpc_flowlogs.arn
}
