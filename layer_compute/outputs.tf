output "instance-ids" {
  value = "${aws_instance.instance.*.id}"
}

output "elasticache-cluster_address" {
  value = "${aws_elasticache_replication_group.elasticache-cluster.configuration_endpoint_address}"
}

# output "elastisearch-endpoint" {
#   value = "${aws_elasticsearch_domain.elasticsearch-cluster.endpoint}"
# }
#
# output "elastisearch-kibana-endpoint" {
#   value = "${aws_elasticsearch_domain.elasticsearch-cluster.kibana_endpoint}"
# }

output "security-group-id" {
  value = "${aws_security_group.static_cluster_sg.id}"
}

output "instance-ips" {
  value = "${join(",",aws_instance.instance.*.private_ip)}"
}
