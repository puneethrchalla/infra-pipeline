# AWS Region
variable "aws_region" {}

# Environment
variable "environment" {}

# Max retries
variable "max_retries" {}

# IAM Assume Roles
variable "roles" {
  type = "map"

  default = {
    preprod = "998179695351"
    prod    = "356412720976"
  }
}

# TAGS
variable "owner" {
  default = "Brad"
}

variable "project" {
  default = "DBPP"
}
