resource "aws_security_group" "mgmt_trusted_sg" {
  vpc_id = "${aws_vpc.VPC.id}"
  name   = "${var.project}-${var.environment}-SG-BASTION-TRUSTED"

  ingress = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.50/32"]
  }

  ingress = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.141/32"]
  }

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner       = "Brad"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-SG-MGMT-TRUSTED"
  }
}
