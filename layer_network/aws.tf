provider "aws" {
  max_retries = "${var.max_retries}"
  region      = "${var.aws_region}"

  assume_role {
    role_arn     = "arn:aws:iam::${lookup(var.roles, var.environment)}:role/Jenkins-Admin"
    session_name = "DPP-Session"
  }
}
