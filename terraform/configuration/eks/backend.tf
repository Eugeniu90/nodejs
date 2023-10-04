terraform {
  backend "s3" {
    bucket       = "poc-infrastructure-cloud-terraform-state"
    key          = "k8s-poc"
    region       = "eu-west-1"
    session_name = "terraform"
    profile       = "shared"
  }
}
