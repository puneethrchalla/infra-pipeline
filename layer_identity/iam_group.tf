resource "aws_iam_group" "ADMIN" {
  path = "/"
  name = "${var.admin_group_name}"
}

resource "aws_iam_group" "Autoscaling" {
  path = "/"
  name = "${var.autoscaling_group_name}"
}

resource "aws_iam_group" "CloudwatchGroup" {
  path = "/"
  name = "${var.CloudwatchGroup_name}"
}

resource "aws_iam_group" "Debtpaypro-developer" {
  path = "/"
  name = "${var.Debtpaypro_developer_group_name}"
}

resource "aws_iam_group" "FullEc2S3" {
  path = "/"
  name = "${var.FullEc2S3_group_name}"
}

resource "aws_iam_group" "RDS" {
  path = "/"
  name = "${var.RDS_group_name}"
}

resource "aws_iam_group" "readOnly" {
  path = "/"
  name = "${var.readOnly_group_name}"
}

resource "aws_iam_group" "ElasticSearch" {
  path = "/"
  name = "${var.ElasticSearch_group_name}"
}
