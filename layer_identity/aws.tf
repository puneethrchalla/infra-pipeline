provider "aws" {
  max_retries = "${var.max_retries}"
  region      = "${var.aws_region}"
}
