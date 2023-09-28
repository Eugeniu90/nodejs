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
