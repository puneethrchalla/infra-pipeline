resource "aws_iam_policy_attachment" "autoscaling-policy-attachment" {
  policy_arn = "${aws_iam_policy.AutoScalingFullAccess.arn}"
  roles      = ["${aws_iam_role.AWSServiceRoleForAutoScaling.name}"]
  name       = "autoscaling-policy-attachment"
  groups     = ["${aws_iam_group.Autoscaling.name}"]
}

resource "aws_iam_policy_attachment" "cloudwatch-policy-attachment" {
  policy_arn = "${aws_iam_policy.CloudWatchFullAccess.arn}"
  roles      = ["${aws_iam_role.AWSServiceRoleForCloudwatch.name}"]
  name       = "cloudwatch-policy-attachment"
  groups     = ["${aws_iam_group.CloudwatchGroup.name}"]
}

resource "aws_iam_policy_attachment" "ec2-policy-attachment" {
  policy_arn = "${aws_iam_policy.AmazonEC2FullAccess.arn}"
  roles      = ["${aws_iam_role.FullEc2AndS3.name}"]
  name       = "ec2-policy-attachment"
  groups     = ["${aws_iam_group.FullEc2S3.name}"]
}

resource "aws_iam_policy_attachment" "rds-policy-attachment" {
  policy_arn = "${aws_iam_policy.AmazonRDSFullAccess.arn}"
  roles      = ["${aws_iam_role.AWSServiceRoleForRDS.name}"]
  name       = "rds-policy-attachment"
  groups     = ["${aws_iam_group.RDS.name}"]
}

resource "aws_iam_policy_attachment" "s3-policy-attachment" {
  policy_arn = "${aws_iam_policy.AmazonS3FullAccess.arn}"
  roles      = ["${aws_iam_role.FullEc2AndS3.name}"]
  name       = "s3-policy-attachment"
  groups     = ["${aws_iam_group.FullEc2S3.name}"]
}

resource "aws_iam_policy_attachment" "admin-policy-attachment" {
  policy_arn = "${aws_iam_policy.AdministratorAccess.arn}"
  roles      = ["${aws_iam_role.ADMIN_IAM_ROLE.name}"]
  name       = "admin-policy-attachment"
  groups     = ["${aws_iam_group.ADMIN.name}"]
}

resource "aws_iam_policy_attachment" "elasticsearch-policy-attachment" {
  policy_arn = "${aws_iam_policy.AdministratorAccess.arn}"
  roles      = ["${aws_iam_role.AWSServiceRoleForElasticSearch.name}"]
  name       = "elasticsearch-policy-attachment"
  groups     = ["${aws_iam_group.ElasticSearch.name}"]
}
