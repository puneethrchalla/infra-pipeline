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
