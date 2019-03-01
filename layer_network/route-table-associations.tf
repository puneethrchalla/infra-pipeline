resource "aws_route_table_association" "App_Sub_RT_Assoc" {
  count          = "${var.az_count}"
  route_table_id = "${element(aws_route_table.Private_RT.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.App_Subnet.*.id, count.index)}"
}

resource "aws_route_table_association" "DB_Sub_RT_Assoc" {
  count          = "${var.az_count}"
  route_table_id = "${element(aws_route_table.Private_RT.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.DB_Subnet.*.id, count.index)}"
}

resource "aws_route_table_association" "DMZ_Sub_RT_Assoc" {
  count          = "${var.az_count}"
  route_table_id = "${element(aws_route_table.Public_RT.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.DMZ_Subnet.*.id, count.index)}"
}

resource "aws_route_table_association" "Web_Sub_RT_Assoc" {
  count          = "${var.az_count}"
  route_table_id = "${element(aws_route_table.Private_RT.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.Web_Subnet.*.id, count.index)}"
}
