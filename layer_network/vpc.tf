resource "aws_vpc" "VPC" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Brad"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-VPC"
  }
}