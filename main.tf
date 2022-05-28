# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

resource "aws_key_pair" "cluster_nodes" {
  key_name   = "${var.cluster_name}-control-plane"
  public_key = var.public_key
}

data "template_file" "init" {
  template = file("${path.module}/templates/user_data.sh")
  vars = {
    automated_user          = var.automated_user
    cilium_version          = var.cilium_version
    cilium_cidr             = var.cilium_cidr
    cluster_name            = var.cluster_name
    cluster_cidr            = var.cluster_cidr
    domain_name             = var.domain_name
    env                     = var.env
    istio_version           = var.istio_version
    kubernetes_api_hostname = var.kubernetes_api_hostname
    kubernetes_join_token   = var.kubernetes_join_token
    kubernetes_version      = var.kubernetes_version
  }
}

resource "aws_instance" "control_plane" {
  ami                         = var.ami
  instance_type               = var.instance_type
  user_data                   = data.template_file.init.rendered
  security_groups             = var.security_groups
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.cluster_nodes.key_name
  subnet_id                   = var.subnet_id
  tags = {
    "Name"                                                = "k8s-control-plane"
    "Role"                                                = "control-plane"
    "kubernetes.io/cluster/${var.env}-${var.region_code}" = "owned"
  }
  metadata_options {
    http_endpoint          = enabled
    instance_metadata_tags = "enabled"
  }
  root_block_device {
    encrypted   = false
    volume_size = 25
    volume_type = "gp3"
  }
}
