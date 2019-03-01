variable "app_elb_name" {
  default = "ELB-APP"
  type    = "string"
}

variable "web_elb_name" {
  default = "ELB-WEB"
  type    = "string"
}

variable "static_cluster_elb_name" {
  default = "ELB-CLSTR"
  type    = "string"
}

variable "app_elb_sg_name" {
  default = "SG-APP-ELB"
  type    = "string"
}

variable "web_elb_sg_name" {
  default = "SG-WEB-ELB"
  type    = "string"
}

variable "static_cluster_elb_sg_name" {
  default = "SG-STATIC-CLUSTER-ELB"
  type    = "string"
}
