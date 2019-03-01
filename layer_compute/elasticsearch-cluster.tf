resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "elasticsearch-cluster" {
  domain_name           = "${var.elasticsearch_domain}"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type          = "${var.elasticsearch_instance_type}"
    instance_count         = "${var.elasticsearch_instance_count}"
    zone_awareness_enabled = "${var.elasticsearch_zone_awareness}"

  }

  ebs_options {
    ebs_enabled = true
    volume_type = "standard"
    volume_size = 100
  }

  access_policies = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "es:*",
    "Principal": "*",
    "Effect": "Allow",
    "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.elasticsearch_domain}/*"
  }
]
}
POLICY

  encrypt_at_rest {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  vpc_options {
    security_group_ids = ["${aws_security_group.elasticache-sg.id}"]
    subnet_ids         = ["${element(split(",",data.terraform_remote_state.layer_network.App_Subnet_ID),0)}", "${element(split(",",data.terraform_remote_state.layer_network.App_Subnet_ID),1)}"]
  }

  tags = {
    Domain = "${var.project}-${var.environment}-ELASTICSEARCH-CLUSTER"
  }
}

resource "aws_security_group" "elasticsearch-sg" {
  name   = "${var.project}-${var.environment}-SG-ELASTICSEARCH"
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"

  ingress = {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.layer_network.VPC_Cidr_Block}"]
  }

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-SG-ELASTICSEARCH"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
