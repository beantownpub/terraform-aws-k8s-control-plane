# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

variable "ami" {
  description = "AMI image ID"
}

variable "associate_public_ip_address" { default = false }

variable "automated_user" {
  description = "default user to create a token for"
  default     = null
}

variable "cilium_version" { default = "1.10.5" }
variable "cilium_cidr" { default = "10.7.0.0/16" }
variable "cluster_cidr" { default = "10.96.0.0/12" }
variable "cluster_name" {}
variable "domain_name" {
  description = "The domain you will be pointing at the Istio ingress"
}
variable "env" {}
variable "iam_instance_profile" { default = null }
variable "instance_type" { default = "t3.medium" }
variable "istio_version" { default = "1.12.1" }
variable "kubernetes_api_hostname" {}
variable "kubernetes_join_token" {}
variable "kubernetes_version" { default = "1.24.0" }

variable "private_subnets" { default = [] }
variable "security_groups" { default = [] }
variable "region_code" {}
variable "subnet_id" {
  type    = string
  default = null
}

variable "tags" {
  type        = map(string)
  description = ""
  default     = {}
}

variable "public_key" { default = null }
variable "target_group_arns" {
  default = []
}
