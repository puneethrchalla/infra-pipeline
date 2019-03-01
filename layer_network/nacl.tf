resource "aws_network_acl" "NACL" {
  vpc_id     = "${aws_vpc.VPC.id}"
  subnet_ids = ["${aws_subnet.DMZ_Subnet.*.id}", "${aws_subnet.Web_Subnet.*.id}", "${aws_subnet.App_Subnet.*.id}", "${aws_subnet.DB_Subnet.*.id}"]

  ingress = {
    protocol   = "tcp"
    rule_no    = 10
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress = {
    protocol   = "tcp"
    rule_no    = 20
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress = {
    protocol   = "tcp"
    rule_no    = 30
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress = {
    protocol   = "tcp"
    rule_no    = 40
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress = {
    protocol   = "tcp"
    rule_no    = 90
    action     = "Allow"
    cidr_block = "0.0.0.0/0"
    from_port  = -1
    to_port    = -1
  }

  tags = {
    Name        = "${var.project}-${var.environment}-NACL"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
