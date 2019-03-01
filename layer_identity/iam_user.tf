resource "aws_iam_user" "Brad" {
  path          = "/"
  name          = "${var.iam_user}"
  force_destroy = false
}
