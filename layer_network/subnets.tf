# Application Subnet

resource "aws_subnet" "App_Subnet" {
  count                   = "${var.az_count}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index % var.az_count)}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${cidrsubnet(cidrsubnet(var.vpc_cidr_block, var.az_cidr_newbits, var.az_cidr_length * count.index), 6, 2)}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-SUBNET-APP-AZ${count.index + 1}"
  }
}

# DB Subnet

resource "aws_subnet" "DB_Subnet" {
  count                   = "${var.az_count}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index % var.az_count)}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${cidrsubnet(cidrsubnet(var.vpc_cidr_block, var.az_cidr_newbits, var.az_cidr_length * count.index), 6, 3)}"

  tags = {
    Name        = "${var.project}-${var.environment}-SUBNET-DB-AZ${count.index + 1}"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

# DMZ Subnet

resource "aws_subnet" "DMZ_Subnet" {
  count                   = "${var.az_count}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index % var.az_count)}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${cidrsubnet(cidrsubnet(var.vpc_cidr_block, var.az_cidr_newbits, var.az_cidr_length * count.index), 6, 0)}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-SUBNET-DMZ-AZ${count.index + 1}"
  }
}

# Web Subnet

resource "aws_subnet" "Web_Subnet" {
  count                   = "${var.az_count}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index % var.az_count)}"
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${cidrsubnet(cidrsubnet(var.vpc_cidr_block, var.az_cidr_newbits, var.az_cidr_length * count.index), 6, 1)}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-SUBNET-WEB-AZ${count.index + 1}"
  }
}
