resource "aws_iam_instance_profile" "autoscaling-instance-profile" {
  role = "${aws_iam_role.AWSServiceRoleForAutoScaling.name}"
  name = "${var.autoscaling_instance_profile}"
}

resource "aws_iam_instance_profile" "cloudwatch-instance-profile" {
  role = "${aws_iam_role.AWSServiceRoleForCloudwatch.name}"
  name = "${var.cloudwatch_instance_profile}"
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  role = "${aws_iam_role.FullEc2AndS3.name}"
  name = "${var.ec2_instance_profile}"
}

resource "aws_iam_instance_profile" "rds-instance-profile" {
  role = "${aws_iam_role.AWSServiceRoleForRDS.name}"
  name = "${var.rds_instance_profile}"
}

resource "aws_iam_instance_profile" "s3-fullaccess-instance-profile" {
  role = "${aws_iam_role.FullEc2AndS3.name}"
  name = "${var.s3_fullaccess_instance_profile}"
}
