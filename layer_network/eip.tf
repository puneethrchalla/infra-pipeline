resource "aws_eip" "GTWY_EIP" {
  count = "${var.az_count}"
  vpc   = true
}
