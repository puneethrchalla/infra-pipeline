resource "aws_route_table" "Public_RT" {
  count                  = "${var.az_count}"
  vpc_id = "${aws_vpc.VPC.id}"

  tags = {
    Owner       = "Brad"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-PUB-RT"
  }
}

resource "aws_route_table" "Private_RT" {
  count                  = "${var.az_count}"
  vpc_id = "${aws_vpc.VPC.id}"

  tags = {
    Owner       = "Brad"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-PRI-RT"
  }
}
