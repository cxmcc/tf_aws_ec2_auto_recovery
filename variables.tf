variable "name" {}
variable "count" {}
variable "ami" {}
variable "instance_type" {}

variable "subnet_ids" {
  type = "list"
}

variable "key_name" {}

variable "user_data" {
  default = ""
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "route53_hosted_zone_id" {}
variable "health_check_path" {}
variable "domain" {}
