variable "rds-app" {
  type = "string"

  default = "MARIADB"
}

variable "failback" {}

variable "domain-name" {
  type    = "string"
  default = "dbpp-dev.com"
}

variable "multi-az" {}

variable "admin-id" {
  type    = "string"
  default = "dbadmin"
}

variable "unique_id" {
  type    = "string"
  default = "7962bf"
}

variable "source-instance-name" {
  type    = "string"
  default = "dbpp-rds-source"
}

variable "backup-retention" {
  type    = "string"
  default = "7"
}

variable "db-port" {
  type    = "string"
  default = "3306"
}

variable "read_replica_identifier" {
  type    = "list"
  default = ["dbpp-rds-rr-1", "dbpp-rds-rr-2"]
}

variable "instance-type" {
  type    = "string"
  default = "db.r4.4xlarge"
}

variable "storage-size" {
  type    = "string"
  default = "1000"
}

variable "role" {
  type    = "string"
  default = "Database"
}

variable "tier" {
  type    = "string"
  default = "DB"
}

variable "prod_kms_key_alias" {
  type    = "string"
  default = "DBPP-KMS-DB-PROD"
}

variable "nonprod_kms_key_alias" {
  type    = "string"
  default = "DBPP-KMS-DB-NONPROD"
}
