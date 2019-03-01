output "app_elb_id" {
  "value" = "${aws_elb.app_elb.id}"
}

output "app_elb_name" {
  "value" = "${aws_elb.app_elb.name}"
}

output "app_elb_fqdn" {
  value = "${aws_elb.app_elb.dns_name}"
}

output "web_elb_fqdn" {
  value = "${aws_elb.web_elb.dns_name}"
}

output "web_elb_id" {
  value = "${aws_elb.web_elb.id}"
}

output "web_elb_name" {
  value = "${aws_elb.web_elb.name}"
}

output "web_elb_sg" {
  value = "${aws_security_group.web_elb_sg.id}"
}

output "app_elb_sg" {
  "value" = "${aws_security_group.app_elb_sg.id}"
}

output "static_cluster_elb_sg" {
  value = "${aws_security_group.static_cluster_elb_sg.id}"
}

output "static_cluster_elb_fqdn" {
  value = "${aws_elb.static_cluster_elb.dns_name}"
}

output "static_cluster_elb_id" {
  value = "${aws_elb.static_cluster_elb.id}"
}

output "static_cluster_elb_name" {
  value = "${aws_elb.static_cluster_elb.name}"
}
