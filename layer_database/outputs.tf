output "dsg-name" {
  value = "${aws_db_subnet_group.db-subnet-group.name}"
}

output "sg" {
  value = "${aws_security_group.Mariadb-sg.id}"
}

output "instance-identifier" {
  value = "${aws_db_instance.Mariadb.id}"
}

output "instance-arn" {
  value = "${aws_db_instance.Mariadb.arn}"
}

output "kms-key-id" {
  value = "${aws_db_instance.Mariadb.kms_key_id}"
}

output "pg-name" {
  value = "${aws_db_parameter_group.mariadb-parameter-group-primary.name}"
}

output "arn" {
  value = "${aws_db_instance.Mariadb.arn}"
}

output "db-subnet-ids" {
  value = "${aws_db_subnet_group.db-subnet-group.subnet_ids}"
}

output "mariadb-endpoint" {
  value = "${aws_db_instance.Mariadb.endpoint}"
}

output "address" {
  value = "${aws_db_instance.Mariadb.address}"
}

output "readreplica-endpoints" {
  "value" = "${join(",",aws_db_instance.Mariadb-Replica.*.id)}"
}
