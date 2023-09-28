locals {
  aws_account                        = data.aws_caller_identity.current.account_id
  ansible_version                    = "2.11.12"
  availability_zones                 = var.availability_zones_map[var.aws_region]
  cluster_name                       = "poc-eks-cluster"
  rds_application_password_is_set    = var.rds_application_password != null && var.rds_application_password != ""
  rds_application_password           = local.rds_application_password_is_set ? var.rds_application_password : join("", random_password.rds_application_password.*.result)
  tags = merge(
  var.common_tags,
  {
    Name        = "poc"
    Environment = terraform.workspace
    Application = "MVP"
    TagVersion  = "1"
  }
  )
}
