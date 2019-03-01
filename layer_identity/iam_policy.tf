resource "aws_iam_policy" "AdministratorAccess" {
  path   = "/"
  name   = "${var.iam_admin_policy}"
  policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"*\",\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"
}

resource "aws_iam_policy" "AmazonEC2FullAccess" {
  path   = "/"
  name   = "${var.AmazonEC2FullAccess_iam_policy}"
  policy = "{\r\n    \"Version\": \"2012-10-17\",\r\n    \"Statement\": [\r\n        {\r\n            \"Effect\": \"Allow\",\r\n            \"Action\": \"ec2:*\",\r\n            \"Resource\": \"*\"\r\n        }        \r\n    ]\r\n}"
}

resource "aws_iam_policy" "AmazonRDSFullAccess" {
  path   = "/"
  name   = "${var.rds_iam_policy}"
  policy = "{\r\n    \"Version\": \"2012-10-17\",\r\n    \"Statement\": [\r\n        {\r\n            \"Effect\": \"Allow\",\r\n            \"Action\": \"rds:*\",\r\n            \"Resource\": \"*\"\r\n        }        \r\n    ]\r\n}"
}

resource "aws_iam_policy" "AmazonS3FullAccess" {
  path   = "/"
  name   = "${var.AmazonS3FullAccess_iam_policy}"
  policy = "{\r\n  \"Version\": \"2012-10-17\",\r\n  \"Statement\": [\r\n    {\r\n      \"Effect\": \"Allow\",\r\n      \"Action\": \"s3:*\",\r\n      \"Resource\": \"*\"\r\n    }\r\n  ]\r\n}"
}

resource "aws_iam_policy" "AutoScalingFullAccess" {
  path   = "/"
  name   = "${var.autoscaling_iam_policy}"
  policy = "{\r\n    \"Version\": \"2012-10-17\",\r\n    \"Statement\": [\r\n        {\r\n            \"Effect\": \"Allow\",\r\n            \"Action\": \"autoscaling:*\",\r\n            \"Resource\": \"*\"\r\n        }        \r\n    ]\r\n}"
}

resource "aws_iam_policy" "CloudWatchFullAccess" {
  path   = "/"
  name   = "${var.cloudwatch_iam_policy}"
  policy = "{\r\n    \"Version\": \"2012-10-17\",\r\n    \"Statement\": [\r\n        {\r\n            \"Effect\": \"Allow\",\r\n            \"Action\": \"cloudwatch:*\",\r\n            \"Resource\": \"*\"\r\n        }        \r\n    ]\r\n}"
}

resource "aws_iam_policy" "ElasticSearchFullAccess" {
  path   = "/"
  name   = "${var.elasticsearch_iam_policy}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "ReadOnlyAccess" {
  path   = "/"
  name   = "${var.ReadOnlyAccess_name}"
  policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": [\n        \"acm:DescribeCertificate\",\n        \"acm:GetCertificate\",\n        \"acm:ListCertificates\",\n        \"appstream:Get*\",\n        \"autoscaling:Describe*\",\n        \"cloudformation:DescribeStackEvents\",\n        \"cloudformation:DescribeStackResource\",\n        \"cloudformation:DescribeStackResources\",\n        \"cloudformation:DescribeStacks\",\n        \"cloudformation:GetTemplate\",\n        \"cloudformation:List*\",\n        \"cloudfront:Get*\",\n        \"cloudfront:List*\",\n        \"cloudsearch:Describe*\",\n        \"cloudsearch:List*\",\n        \"cloudtrail:DescribeTrails\",\n        \"cloudtrail:GetTrailStatus\",\n        \"cloudwatch:Describe*\",\n        \"cloudwatch:Get*\",\n        \"cloudwatch:List*\",\n        \"codecommit:BatchGetRepositories\",\n        \"codecommit:Get*\",\n        \"codecommit:GitPull\",\n        \"codecommit:List*\",\n        \"codedeploy:Batch*\",\n        \"codedeploy:Get*\",\n        \"codedeploy:List*\",\n        \"config:Deliver*\",\n        \"config:Describe*\",\n        \"config:Get*\",\n        \"datapipeline:DescribeObjects\",\n        \"datapipeline:DescribePipelines\",\n        \"datapipeline:EvaluateExpression\",\n        \"datapipeline:GetPipelineDefinition\",\n        \"datapipeline:ListPipelines\",\n        \"datapipeline:QueryObjects\",\n        \"datapipeline:ValidatePipelineDefinition\",\n        \"directconnect:Describe*\",\n        \"dynamodb:BatchGetItem\",\n        \"dynamodb:DescribeTable\",\n        \"dynamodb:GetItem\",\n        \"dynamodb:ListTables\",\n        \"dynamodb:Query\",\n        \"dynamodb:Scan\",\n        \"ec2:Describe*\",\n        \"ec2:GetConsoleOutput\",\n        \"ecr:GetAuthorizationToken\",\n        \"ecr:BatchCheckLayerAvailability\",\n        \"ecr:GetDownloadUrlForLayer\",\n        \"ecr:GetManifest\",\n        \"ecr:DescribeRepositories\",\n        \"ecr:ListImages\",\n        \"ecr:BatchGetImage\",\n        \"ecs:Describe*\",\n        \"ecs:List*\",\n        \"elasticache:Describe*\",\n        \"elasticache:List*\",\n        \"elasticbeanstalk:Check*\",\n        \"elasticbeanstalk:Describe*\",\n        \"elasticbeanstalk:List*\",\n        \"elasticbeanstalk:RequestEnvironmentInfo\",\n        \"elasticbeanstalk:RetrieveEnvironmentInfo\",\n        \"elasticloadbalancing:Describe*\",\n        \"elasticmapreduce:Describe*\",\n        \"elasticmapreduce:List*\",\n        \"elastictranscoder:List*\",\n        \"elastictranscoder:Read*\",\n        \"es:DescribeElasticsearchDomain\",\n        \"es:DescribeElasticsearchDomains\",\n        \"es:DescribeElasticsearchDomainConfig\",\n        \"es:ListDomainNames\",\n        \"es:ListTags\",\n        \"es:ESHttpGet\",\n        \"es:ESHttpHead\",\n        \"events:DescribeRule\",\n        \"events:ListRuleNamesByTarget\",\n        \"events:ListRules\",\n        \"events:ListTargetsByRule\",\n        \"events:TestEventPattern\",\n        \"firehose:Describe*\",\n        \"firehose:List*\",\n        \"glacier:ListVaults\",\n        \"glacier:DescribeVault\",\n        \"glacier:GetDataRetrievalPolicy\",\n        \"glacier:GetVaultAccessPolicy\",\n        \"glacier:GetVaultLock\",\n        \"glacier:GetVaultNotifications\",\n        \"glacier:ListJobs\",\n        \"glacier:ListMultipartUploads\",\n        \"glacier:ListParts\",\n        \"glacier:ListTagsForVault\",\n        \"glacier:DescribeJob\",\n        \"glacier:GetJobOutput\",\n        \"iam:GenerateCredentialReport\",\n        \"iam:Get*\",\n        \"iam:List*\",\n        \"inspector:Describe*\",\n        \"inspector:Get*\",\n        \"inspector:List*\",\n        \"inspector:LocalizeText\",\n        \"inspector:PreviewAgentsForResourceGroup\",\n        \"iot:Describe*\",\n        \"iot:Get*\",\n        \"iot:List*\",\n        \"kinesis:Describe*\",\n        \"kinesis:Get*\",\n        \"kinesis:List*\",\n        \"kms:Describe*\",\n        \"kms:Get*\",\n        \"kms:List*\",\n        \"lambda:List*\",\n        \"lambda:Get*\",\n        \"logs:Describe*\",\n        \"logs:Get*\",\n        \"logs:TestMetricFilter\",\n        \"mobilehub:GetProject\",\n        \"mobilehub:ListAvailableFeatures\",\n        \"mobilehub:ListAvailableRegions\",\n        \"mobilehub:ListProjects\",\n        \"mobilehub:ValidateProject\",\n        \"mobilehub:VerifyServiceRole\",\n        \"opsworks:Describe*\",\n        \"opsworks:Get*\",\n        \"rds:Describe*\",\n        \"rds:ListTagsForResource\",\n        \"redshift:Describe*\",\n        \"redshift:ViewQueriesInConsole\",\n        \"route53:Get*\",\n        \"route53:List*\",\n        \"route53domains:CheckDomainAvailability\",\n        \"route53domains:GetDomainDetail\",\n        \"route53domains:GetOperationDetail\",\n        \"route53domains:ListDomains\",\n        \"route53domains:ListOperations\",\n        \"route53domains:ListTagsForDomain\",\n        \"s3:Get*\",\n        \"s3:List*\",\n        \"sdb:GetAttributes\",\n        \"sdb:List*\",\n        \"sdb:Select*\",\n        \"ses:Get*\",\n        \"ses:List*\",\n        \"sns:Get*\",\n        \"sns:List*\",\n        \"sqs:GetQueueAttributes\",\n        \"sqs:ListQueues\",\n        \"sqs:ReceiveMessage\",\n        \"storagegateway:Describe*\",\n        \"storagegateway:List*\",\n        \"swf:Count*\",\n        \"swf:Describe*\",\n        \"swf:Get*\",\n        \"swf:List*\",\n        \"tag:Get*\",\n        \"trustedadvisor:Describe*\",\n        \"waf:Get*\",\n        \"waf:List*\",\n        \"workspaces:Describe*\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"
}
