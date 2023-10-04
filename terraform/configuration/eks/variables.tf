variable "aws_profile" {
  description = "Profile used for session."
}

variable "env_id" {
  description = "Environment ID [dev, int] and so on."
}

variable "availability_zones_map" {
  description = "Maps region to AZs"
  type        = map(any)
}

variable "aws_region" {
  description = "Region to build in"
}

variable "cidr_prefix" {
  description = "CIDR prefix for VPC"
}
variable "common_tags" {
  description = "A common list of tags used across infrastructure"
  type        = map(any)
}

variable "rds_application_password" {
  type        = string
  default     = null
  description = "Application password"
}
variable "ssm_parameter_name_format" {
  type        = string
  default     = "/%s/%s"
  description = "SSM parameter name format"
}

variable "ssm_path" {
  type        = string
  default     = "db"
  description = "SSM path"
}

variable "poc_version_db" {default = "12.8"}
