variable Owner {
  type    = "string"
  default = "reandcloud"
}

variable "unique_id" {
  type    = "string"
  default = "109c4f"
}

variable "az_count" {
  type    = "string"
  default = 2
}

variable "key_pair" {
  type    = "string"
  default = "unknown"
}

variable "created_by" {
  type    = "string"
  default = "Ozair Tukhi"
}

variable "az_cidr_newbits" {
  type    = "string"
  default = 1
}

variable "deploy_ip" {
  type    = "string"
  default = "72.196.48.126/32"
}

variable "destination_cidr_block" {
  type    = "string"
  default = "0.0.0.0/0"
}

variable "instance_tenancy" {
  type    = "string"
  default = "default"
}

variable "az_cidr_length" {
  type    = "string"
  default = 1
}

variable "vpc_cidr_block" {}

# DNS
variable "zone_id" {
  type    = "string"
  default = "Z3VXKH3X9Q3ZWE"
}
