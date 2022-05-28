# terraform-aws-k8s-control-plane
Terraform module for creating a Kubernetes control-plane node

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.16.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.control_plane](https://registry.terraform.io/providers/hashicorp/aws/4.16.0/docs/resources/instance) | resource |
| [aws_key_pair.cluster_nodes](https://registry.terraform.io/providers/hashicorp/aws/4.16.0/docs/resources/key_pair) | resource |
| [template_file.init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI image ID | `any` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | n/a | `bool` | `false` | no |
| <a name="input_automated_user"></a> [automated\_user](#input\_automated\_user) | default user to create a token for | `any` | `null` | no |
| <a name="input_cilium_cidr"></a> [cilium\_cidr](#input\_cilium\_cidr) | n/a | `string` | `"10.7.0.0/16"` | no |
| <a name="input_cilium_version"></a> [cilium\_version](#input\_cilium\_version) | n/a | `string` | `"1.10.5"` | no |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input\_cluster\_cidr) | n/a | `string` | `"10.96.0.0/12"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `any` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain you will be pointing at the Istio ingress | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `any` | n/a | yes |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | n/a | `any` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.medium"` | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | n/a | `string` | `"1.12.1"` | no |
| <a name="input_kubernetes_api_hostname"></a> [kubernetes\_api\_hostname](#input\_kubernetes\_api\_hostname) | n/a | `any` | n/a | yes |
| <a name="input_kubernetes_join_token"></a> [kubernetes\_join\_token](#input\_kubernetes\_join\_token) | n/a | `any` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | n/a | `string` | `"1.24.0"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list` | `[]` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `any` | `null` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | n/a | `any` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | `list` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | n/a | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance"></a> [instance](#output\_instance) | n/a |
| <a name="output_private_ipv4"></a> [private\_ipv4](#output\_private\_ipv4) | n/a |
<!-- END_TF_DOCS -->
