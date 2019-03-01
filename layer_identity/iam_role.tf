resource "aws_iam_role" "AWSServiceRoleForAutoScaling" {
  name               = "${var.autoscaling_iam_role}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}

resource "aws_iam_role" "AWSServiceRoleForCloudwatch" {
  name               = "${var.cloudwatch_iam_role}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}

resource "aws_iam_role" "AWSServiceRoleForRDS" {
  name               = "${var.rds_iam_role}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}

resource "aws_iam_role" "FullEc2AndS3" {
  name               = "${var.FullEc2AndS3_iam_role}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}

resource "aws_iam_role" "ADMIN_IAM_ROLE" {
  name               = "${var.admin_role_name}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\",\n         \"AWS\": \"arn:aws:iam::835409741984:root\"      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}

resource "aws_iam_role" "AWSServiceRoleForElasticSearch" {
  name               = "${var.elasticsearch_iam_role}"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"
}
