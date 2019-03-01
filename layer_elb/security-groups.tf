resource "aws_security_group" "app_elb_sg" {
  name   = "${var.project}-${var.environment}-${var.app_elb_sg_name}"
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"

  egress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.app_elb_sg_name}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "web_elb_sg" {
  name   = "${var.project}-${var.environment}-${var.web_elb_sg_name}"
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"

  ingress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  ingress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  egress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.web_elb_sg_name}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "static_cluster_elb_sg" {
  name   = "${var.project}-${var.environment}-${var.static_cluster_elb_sg_name}"
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"

  egress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.static_cluster_elb_sg_name}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
