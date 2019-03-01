output "instance-ids" {
  value = "${aws_instance.instance.*.id}"
}
