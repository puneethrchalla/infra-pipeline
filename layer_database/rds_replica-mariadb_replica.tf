resource "aws_db_instance" "Mariadb-Replica" {
  count                       = 2
  apply_immediately           = false
  storage_type                = "io1"
  publicly_accessible         = false
  identifier                  = "dbpp-${var.environment}-rds-read-replica-${count.index + 1}"
  auto_minor_version_upgrade  = true
  backup_retention_period     = "${var.backup-retention}"
  multi_az                    = true
  skip_final_snapshot         = true
  allocated_storage           = "${var.storage-size}"
  password                    = "${var.admin-id}!"
  instance_class              = "${var.instance-type}"
  port                        = "${var.db-port}"
  engine                      = "${var.rds-app}"
  parameter_group_name        = "${aws_db_parameter_group.mariadb-parameter-group-primary.name}"
  vpc_security_group_ids      = ["${aws_security_group.Mariadb-sg.id}"]
  copy_tags_to_snapshot       = false
  storage_encrypted           = true
  kms_key_id                  = "${aws_kms_key.Mariadb-KMS.arn}"
  engine_version              = "10.2.15"
  monitoring_interval         = "0"
  replicate_source_db         = "${aws_db_instance.Mariadb.id}"
  allow_major_version_upgrade = false
  username                    = "${var.admin-id}"
  iops                        = "5000"

  tags = {
    Name                = "${var.project}-${var.environment}-${var.tier}-READ-REPLICA-${count.index + 1}"
    Project             = "${var.project}"
    Environment         = "${var.environment}"
    Resource            = "RDS"
    Tier                = "${var.tier}"
    Role                = "${var.role}"
    Monitoring          = "No"
    AMI_Backup_Policy   = "N/A"
    Service             = "${var.tier}"
    Owner               = "${var.owner}"
    SecurityAgentStatus = "False"
  }
}
