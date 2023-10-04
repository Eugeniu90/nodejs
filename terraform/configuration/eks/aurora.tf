module "db" {
  
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = "${lower(terraform.workspace)}-poc"
  engine         = "aurora-postgresql"
  engine_version = var.poc_version_db
  instance_type  = "db.t3.medium"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  replica_count           = 1
  allowed_security_groups = [aws_security_group.aurora_rds.id]
  allowed_cidr_blocks     = module.vpc.private_subnets_cidr_blocks

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 60

  db_parameter_group_name         = aws_db_parameter_group.poc.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.poc.id

  username                            = "postgres"
  password                            = local.rds_application_password
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  tags                                = local.tags

}

resource "random_password" "rds_application_password" {
  length  = 16
  special = false
}


resource "aws_ssm_parameter" "rds_application_password" {
  name        = format(var.ssm_parameter_name_format, var.ssm_path, "${lower(terraform.workspace)}-poc")
  value       = local.rds_application_password
  description = "Aurora password for the application user"
  type        = "SecureString"
}
resource "aws_security_group" "aurora_rds" {
  name        = "${lower(terraform.workspace)}_aurora"
  description = "Allow RDS network in place"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 5432
    protocol = "tcp"
    to_port = 5432
    cidr_blocks =  module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}


resource "aws_db_parameter_group" "poc" {
  
  name        = "${lower(terraform.workspace)}-aurora-postgresql12-poc-parameter-group"
  family      = "aurora-postgresql12"
  description = "${lower(terraform.workspace)}-aurora-postgresql12-poc-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "poc" {
  
  name        = "${lower(terraform.workspace)}-aurora-57-cluster-parameter-group"
  family      = "aurora-postgresql12"
  description = "${lower(terraform.workspace)}-aurora-57-cluster-parameter-group"
  tags        = local.tags
}
