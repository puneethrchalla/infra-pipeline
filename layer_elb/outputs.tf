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
