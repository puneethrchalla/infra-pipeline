# Internet Gateway

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.VPC.id}"

  tags = {
    Name        = "${var.project}-${var.environment}-IGW"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

# NAT Gateway

resource "aws_nat_gateway" "Nat_GTWY" {
  count         = "${var.az_count}"
  allocation_id = "${element(aws_eip.GTWY_EIP.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.DMZ_Subnet.*.id, count.index)}"

  tags = {
    Name        = "${var.project}-${var.environment}-NAT-AZ${count.index + 1}"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
