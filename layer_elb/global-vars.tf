# AWS Region
variable "aws_region" {
  default = "us-east-1"
}

# Environment
variable "environment" {
  default = "Dev"
}

# Max retries
variable "max_retries" {
  default = "15"
}

# TAGS
variable "owner" {
  default = "Puneeth"
}

variable "project" {
  default = "HV-Internal"
}
