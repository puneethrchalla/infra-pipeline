resource "aws_db_subnet_group" "db-subnet-group" {
  subnet_ids  = ["${element(split(",",data.terraform_remote_state.layer_network.DB_Subnet_ID),0)}", "${element(split(",",data.terraform_remote_state.layer_network.DB_Subnet_ID),1)}"]
  name        = "db-subnet-group"
  description = "RDS subnets"
}

resource "aws_db_parameter_group" "mariadb-parameter-group-primary" {
  parameter = {
    name         = "innodb_buffer_pool_size"
    value        = "96636764160"
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "log_bin_trust_function_creators"
    value        = 1
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "innodb_buffer_pool_instances"
    value        = 64
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "innodb_autoinc_lock_mode"
    value        = 2
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "connect_timeout"
    value        = 31536000
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "net_read_timeout"
    value        = 31536000
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "net_write_timeout"
    value        = 31536000
    apply_method = "pending-reboot"
  }

  parameter = {
    name         = "skip_name_resolve"
    value        = "1"
    apply_method = "pending-reboot"
  }

  name        = "mariadb-parameter-group-primary"
  description = "MariaDB parameters"
  family      = "mariadb10.2"

  tags = {
    Name        = "${var.project}-${var.environment}-primary-mariadb-parameter-group"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "Mariadb-sg" {
  vpc_id = "${data.terraform_remote_state.layer_network.vpc_id}"
  name   = "${var.project}-${var.environment}-SG-${var.rds-app}"

  ingress = {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.layer_network.VPC_Cidr_Block}"]
  }

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-SG-${var.rds-app}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_kms_key" "Mariadb-KMS" {
  description             = "KMS Key for MariaDB instances"
  deletion_window_in_days = 20
}

resource "aws_db_instance" "Mariadb" {
  apply_immediately           = false
  storage_type                = "io1"
  publicly_accessible         = false
  identifier                  = "dbpp-${var.environment}-rds-source"
  auto_minor_version_upgrade  = true
  backup_retention_period     = "${var.backup-retention}"
  multi_az                    = "${var.multi-az}"
  skip_final_snapshot         = true
  allocated_storage           = "${var.storage-size}"
  password                    = "${var.admin-id}!"
  instance_class              = "${var.instance-type}"
  port                        = "${var.db-port}"
  engine                      = "${var.rds-app}"
  parameter_group_name        = "${aws_db_parameter_group.mariadb-parameter-group-primary.name}"
  name                        = "conexus"
  copy_tags_to_snapshot       = false
  vpc_security_group_ids      = ["${aws_security_group.Mariadb-sg.id}"]
  storage_encrypted           = true
  kms_key_id                  = "${aws_kms_key.Mariadb-KMS.arn}"
  db_subnet_group_name        = "${aws_db_subnet_group.db-subnet-group.name}"
  engine_version              = "10.2.15"
  allow_major_version_upgrade = false
  username                    = "${var.admin-id}"
  iops                        = "5000"

  tags = {
    Name                = "${var.project}-${var.environment}-RDS-SOURCE"
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
