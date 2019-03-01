# STATIC CLUSTER VARS

variable "instance_app_name" {
  type    = "list"
  default = ["static-cluster-1", "static-cluster-2", "static-cluster-3"]
}

variable "az" {
  type    = "list"
  default = ["us-west-1a", "us-west-1b", "us-west-1c"]
}

variable "elasticsearch_domain" {
  type    = "string"
  default = "dpp-elasticsearch"
}

variable "placement_gp_name" {
  type    = "string"
  default = "static-cluster-pg"
}

variable "autoscaling_iam_profile" {
  default = "AUTOSCALING_INSTANCE_PROFILE"
}

variable "ec2_instance_profile" {
  default = "EC2_INSTANCE_PROFILE"
}

variable "volume_size" {
  default = "50"
}

variable "cluster_ami_id" {}

variable "role" {
  default = "Cluster"
}

variable "tier" {
  default = "APP"
}

variable "sg_name" {
  type    = "string"
  default = "test_sg"
}

variable "key_name" {
  type    = "string"
  default = "test_keypair"
}

variable "static_instance_type" {}

variable "static_instance_count" {}


# ELASTICACHE VARS

variable "parameter_group_name" {
  type    = "string"
  default = "default.redis5.0.cluster.on"
}

variable "engine_version" {
  type    = "string"
  default = "5.0.0"
}

variable "port" {
  type    = "string"
  default = "6379"
}

variable "node_type" {
  "type"    = "string"
  "default" = "cache.t2.medium"
}

variable "unique_id" {
  "type"    = "string"
  "default" = "919432"
}

variable "engine" {
  "type"    = "string"
  "default" = "redis"
}

variable "user-email" {
  "type"    = "string"
  "default" = "test@example.com"
}

# Vault
variable "vault_ip" {
  default = "10.0.129.194"
}

variable "vault_port" {
  default = "8200"
}

#ELASTICSEARCH VARIABLES
variable "elasticsearch_instance_type" {}

variable "elasticsearch_instance_count" {}

variable "elasticsearch_zone_awareness" {}
