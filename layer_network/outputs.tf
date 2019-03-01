output "DB_Subnet_ID" {
  "value" = "${join(",",aws_subnet.DB_Subnet.*.id)}"
}

output "Account_ID" {
  "value" = "${data.aws_caller_identity.current.account_id}"
}

output "Web_Subnet_ID" {
  "value" = "${join(",",aws_subnet.Web_Subnet.*.id)}"
}

output "DMZ_Subnet_ID" {
  "value" = "${join(",",aws_subnet.DMZ_Subnet.*.id)}"
}

output vpc_id {
  "value" = "${aws_vpc.VPC.id}"
}

output az_count {
  "value" = "${var.az_count}"
}

output "App_Subnet_ID" {
  "value" = "${join(",",aws_subnet.App_Subnet.*.id)}"
}

output "VPC_Cidr_Block" {
  "value" = "${aws_vpc.VPC.cidr_block}"
}

output "Main_RTB_Id" {
  "value" = "${aws_vpc.VPC.main_route_table_id}"
}

output "mgmt_trusted_sg" {
  "value" = "${aws_security_group.mgmt_trusted_sg.id}"
}

output "NACL_id" {
  "value" = "${aws_network_acl.NACL.id}"
}

output "Public_RT" {
  "value" = "${join(",",aws_route_table.Public_RT.*.id)}"
}

output "Private_RT" {
  "value" = "${join(",",aws_route_table.Private_RT.*.id)}"
}

output "IGW" {
  "value" = "${aws_internet_gateway.IGW.id}"
}
