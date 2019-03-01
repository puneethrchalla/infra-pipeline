resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  bucket = "${var.s3_name}"

  force_destroy = false

  acl = "private"

  region = "${var.s3_aws_region}"

  tags = {
    Name        = "${var.s3_name}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  policy = "{\r\n  \"Version\": \"2012-10-17\",\r\n  \"Statement\": [\r\n    {\r\n      \"Sid\": \"AWSCloudTrailAclCheck20131101\",\r\n      \"Effect\": \"Allow\",\r\n      \"Principal\": {\r\n        \"Service\": \"cloudtrail.amazonaws.com\"\r\n         },\r\n      \"Action\": \"s3:GetBucketAcl\",\r\n      \"Resource\": \"arn:aws:s3:::${var.s3_name}\"\r\n    },\r\n    {\r\n      \"Sid\": \"AWSCloudTrailWrite20131101\",\r\n      \"Effect\": \"Allow\",\r\n      \"Principal\": {\r\n        \"Service\": \"cloudtrail.amazonaws.com\"\r\n       },\r\n      \"Action\": \"s3:PutObject\",\r\n      \"Resource\": [\r\n        \"arn:aws:s3:::${var.s3_name}/*\"\r\n      ],\r\n      \"Condition\": {\r\n        \"StringEquals\":\r\n          {\"s3:x-amz-acl\": \"bucket-owner-full-control\"}\r\n      }\r\n    },\r\n    {\r\n      \"Sid\": \"MSRB_DataLake_Account_Permission\",\r\n      \"Effect\": \"Allow\",\r\n      \"Principal\": {\r\n          \"AWS\": \"arn:aws:iam::${var.account_id}:root\"\r\n        },\r\n      \"Action\": \"s3:*\",\r\n      \"Resource\": [\r\n        \"arn:aws:s3:::${var.s3_name}\"\r\n      ]\r\n    },\r\n\r\n   {\r\n       \"Sid\": \"AWSLogDeliveryWrite\",\r\n       \"Effect\": \"Allow\",\r\n       \"Principal\": {\"Service\": \"delivery.logs.amazonaws.com\"},\r\n       \"Action\": \"s3:*\",\r\n       \"Resource\": [\r\n                  \"arn:aws:s3:::${var.s3_name}\",\r\n                 \"arn:aws:s3:::${var.s3_name}/*\"\r\n          ],\r\n       \"Condition\": {\"StringEquals\": {\"s3:x-amz-acl\": \"bucket-owner-full-control\"}}\r\n    },\r\n    {\r\n        \"Sid\": \"AWSLogDeliveryAclCheck\",\r\n        \"Effect\": \"Allow\",\r\n       \"Principal\": {\"Service\": \"delivery.logs.amazonaws.com\"},\r\n       \"Action\": \"s3:GetBucketAcl\",\r\n       \"Resource\": \"arn:aws:s3:::${var.s3_name}\"\r\n    }\r\n  ]\r\n}"
}
