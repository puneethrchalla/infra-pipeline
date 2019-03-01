variable "rds_iam_role" {
  type    = "string"
  default = "RDS_IAM_ROLE"
}

variable "autoscaling_iam_policy" {
  type    = "string"
  default = "AUTOSCALING_FULLACCESS_IAM_POLICY"
}

variable "cloudwatch_iam_policy" {
  type    = "string"
  default = "CLOUDWATCH_FULLACCESS_IAM_POLICY"
}

variable "cloudwatch_instance_profile" {
  type    = "string"
  default = "CLOUDWATCH_INSTANCE_PROFILE"
}

variable "autoscaling_group_name" {
  type    = "string"
  default = "AUTOSCALING_GROUP"
}

variable "AmazonS3FullAccess_iam_policy" {
  type    = "string"
  default = "S3_FULLACCESS_IAM_POLICY"
}

variable "RDS_group_name" {
  type    = "string"
  default = "RDS_GROUP"
}

variable "s3_aws_region" {
  type    = "string"
  default = "us-west-1"
}

variable "readonly_group_name" {
  type    = "string"
  default = "READONLY_GROUP,DBPP_DEVELOPER_GROUP"
}

variable "CloudwatchGroup_name" {
  type    = "string"
  default = "CLOUDWATCH_GROUP"
}

variable "FullEc2S3_group_name" {
  type    = "string"
  default = "EC2_S3_GROUP"
}

variable "AmazonEC2FullAccess_iam_policy" {
  type    = "string"
  default = "EC2_FULLACCESS_IAM_POLICY"
}

variable "readOnly_group_name" {
  type    = "string"
  default = "READONLY_GROUP"
}

variable "rds_instance_profile" {
  type    = "string"
  default = "RDS_INSTANCE_PROFILE"
}

variable "autoscaling_instance_profile" {
  type    = "string"
  default = "AUTOSCALING_INSTANCE_PROFILE"
}

variable "unique_id" {
  type    = "string"
  default = "fd8721"
}

variable "s3_fullaccess_instance_profile" {
  type    = "string"
  default = "S3_INSTANCE_PROFILE"
}

variable "s3_name" {
  type    = "string"
  default = "cloudtrail-s3-nonprod"
}

variable "iam_admin_policy" {
  type    = "string"
  default = "ADMIN_IAM_POLICY"
}

variable "Debtpaypro_developer_group_name" {
  type    = "string"
  default = "DBPP_DEVELOPER_GROUP"
}

variable "ElasticSearch_group_name" {
  type    = "string"
  default = "ELASTICSEARCH_GROUP"
}

variable "cloudwatch_iam_role" {
  type    = "string"
  default = "CLOUDWATCH_IAM_ROLE"
}

variable "ec2_instance_profile" {
  type    = "string"
  default = "EC2_INSTANCE_PROFILE"
}

variable "admin_role_name" {
  type    = "string"
  default = "ADMIN_IAM_ROLE"
}

variable "admin_group_name" {
  type    = "string"
  default = "ADMIN_GROUP"
}

variable "ReadOnlyAccess_name" {
  type    = "string"
  default = "READONLY_IAM_POLICY"
}

variable "rds_iam_policy" {
  type    = "string"
  default = "RDS_FULLACCESS_IAM_POLICY"
}

variable "account_id" {
  type    = "string"
  default = "998179695351"
}

variable "FullEc2AndS3_iam_role" {
  type    = "string"
  default = "EC2_S3_IAM_ROLE"
}

variable "autoscaling_iam_role" {
  type    = "string"
  default = "AUTOSCALING_IAM_ROLE"
}

variable "elasticsearch_iam_policy" {
  type    = "string"
  default = "ELASTICSEARCH_IAM_POLICY"
}

variable "elasticsearch_iam_role" {
  type    = "string"
  default = "ELASTICSEARCH_IAM_ROLE"
}

variable "iam_user" {
  type    = "string"
  default = "Brad"
}
