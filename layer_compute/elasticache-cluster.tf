resource "aws_elasticache_subnet_group" "elasticache-subnetgroup" {
  name       = "elasticache-subnetgroup"
  subnet_ids = ["${element(split(",",data.terraform_remote_state.layer_network.App_Subnet_ID),0)}", "${element(split(",",data.terraform_remote_state.layer_network.App_Subnet_ID),1)}"]
}

resource "aws_security_group" "elasticache-sg" {
  name   = "${var.project}-${var.environment}-SG-ELASTICACHE"
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"

  ingress = {
    from_port   = 6379
    to_port     = 6379
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
    Name        = "${var.project}-${var.environment}-SG-ELASTICACHE"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_elasticache_replication_group" "elasticache-cluster" {
  replication_group_id          = "elasticache-cluster"
  replication_group_description = "DPP Elasticache Cluster"
  node_type                     = "${var.node_type}"
  port                          = "${var.port}"
  engine                        = "${var.engine}"
  parameter_group_name          = "${var.parameter_group_name}"
  engine_version                = "${var.engine_version}"
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  subnet_group_name             = "${aws_elasticache_subnet_group.elasticache-subnetgroup.name}"
  security_group_ids            = ["${aws_security_group.elasticache-sg.id}"]

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 3
  }

  tags = {
    Name        = "${var.project}-${var.environment}-ELASTICACHE-CLUSTER"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
