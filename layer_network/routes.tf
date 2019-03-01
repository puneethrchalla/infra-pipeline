resource "aws_route" "route_to_IGW" {
  count                  = "${var.az_count}"
  route_table_id         = "${element(aws_route_table.Public_RT.*.id, count.index)}"
  destination_cidr_block = "${var.destination_cidr_block}"
  gateway_id             = "${aws_internet_gateway.IGW.id}"
}

resource "aws_route" "route_to_NGW" {
  count                  = "${var.az_count}"
  route_table_id         = "${element(aws_route_table.Private_RT.*.id, count.index)}"
  destination_cidr_block = "${var.destination_cidr_block}"
  gateway_id             = "${element(aws_nat_gateway.Nat_GTWY.*.id, count.index)}"
}
