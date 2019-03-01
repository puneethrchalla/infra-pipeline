resource "aws_vpc" "VPC" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Brad"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${var.project}-${var.environment}-VPC"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = "${var.environment}-priv ${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.VPC.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "null_resource" "zone_association_authorization" {
  provisioner "local-exec" {
    command = "aws route53 create-vpc-association-authorization --hosted-zone-id ${var.zone_id} --vpc VPCRegion=${var.aws_region},VPCId=${aws_vpc.VPC.id} --region us-east-1"
  }
}

resource "aws_route53_zone_association" "vpc_zone_association" {
  depends_on = ["null_resource.zone_association_authorization"]
  zone_id    = "${var.zone_id}"
  vpc_id     = "${aws_vpc.VPC.id}"
}
