data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {
  "current" = true
}
