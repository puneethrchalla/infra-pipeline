# STATIC CLUSTER VARS

variable "instance_app_name" {
  type    = "list"
  default = ["static-cluster-1", "static-cluster-2"]
}

variable "az" {
  type    = "list"
  default = ["us-west-1a", "us-west-1b", "us-west-1c"]
}

variable "ec2_instance_profile" {
  default = "EC2_INSTANCE_PROFILE"
}

variable "volume_size" {
  default = "50"
}

variable "ami_id" {
  default = "ami-09bfcadb25ee95bec"
}

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
  default = "puneeth-demo-brownbag"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = "2"
}


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
