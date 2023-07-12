## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_tencentcloud"></a> [tencentcloud](#requirement\_tencentcloud) | >=1.60.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tencentcloud"></a> [tencentcloud](#provider\_tencentcloud) | >=1.60.22 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tencentcloud_ccn.ccns](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn) | resource |
| [tencentcloud_ccn.inregion_ccns](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn) | resource |
| [tencentcloud_ccn_attachment.ccn_attachment](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn_attachment) | resource |
| [tencentcloud_ccn_attachment.inregion_ccn_attachment](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn_attachment) | resource |
| [tencentcloud_ccn_bandwidth_limit.ccn_limit](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn_bandwidth_limit) | resource |
| [tencentcloud_ccn_bandwidth_limit.inregion_ccn_limit](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/ccn_bandwidth_limit) | resource |
| [tencentcloud_eip.eips](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/eip) | resource |
| [tencentcloud_nat_gateway.nat](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/nat_gateway) | resource |
| [tencentcloud_route_table.rtbs](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/route_table) | resource |
| [tencentcloud_route_table_entry.defaults](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/route_table_entry) | resource |
| [tencentcloud_route_table_entry.entries](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/route_table_entry) | resource |
| [tencentcloud_subnet.subnets](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/subnet) | resource |
| [tencentcloud_vpc.vpcs](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/vpc) | resource |
| [tencentcloud_vpc_route_tables.default_rtbs](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/data-sources/vpc_route_tables) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ccn_attachments"></a> [ccn\_attachments](#input\_ccn\_attachments) | n/a | <pre>map(list(object({<br>      vpc_name = string<br>      vpc_id = string<br>      vpc_region = string<br>      ccn_uin = optional(string)<br>    })))</pre> | `{}` | no |
| <a name="input_ccns"></a> [ccns](#input\_ccns) | n/a | <pre>map(object({<br>    ccn_name = string  // no use<br>    description = string<br>    qos = string // PT, AU(default), AG<br>    charge_type = string // PREPAID, POSTPAID(default)<br>    bandwidth_limit_type = string // INTER_REGION_LIMIT, OUTER_REGION_LIMIT(default)<br>    regions = optional(list(string))<br>    bandwidth_limit = optional(number)<br>    tags = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_default_route_tables"></a> [default\_route\_tables](#input\_default\_route\_tables) | route table | <pre>map(object({<br>    dest_to_hub = optional(map(string))<br>    # 目标CIDR           下一跳<br>    # 自动根据下一跳识别下一跳类型：<br>    # 如果下一跳：<br>    #   是0，       则下一跳类型为 EIP<br>    #   是IP地址，   则下一跳类型为 NORMAL_CVM<br>    #   以pcx开头，  则下一跳类型为 PEERCONNECTION<br>    #   以dcg开头，  则下一跳类型为 DIRECTCONNECT<br>    #   以vpngw开头，则下一跳类型为 VPN<br>    attach_nat_gateway = optional(bool)<br>    nat_gateway_name = optional(string)<br>    nat_gateway_destination_cidr_block = optional(string)<br>    attach_vpc_peerings = optional(bool)<br>    attach_dcg = optional(bool)<br><br>  }))</pre> | `{}` | no |
| <a name="input_inregion_ccn_attachments"></a> [inregion\_ccn\_attachments](#input\_inregion\_ccn\_attachments) | n/a | <pre>map(list(object({<br>    vpc_name = string<br>    vpc_region = string<br>  })))</pre> | `{}` | no |
| <a name="input_inregion_ccns"></a> [inregion\_ccns](#input\_inregion\_ccns) | n/a | <pre>map(object({<br>    ccn_name = string  // no use<br>    description = string<br>    qos = string // PT, AU(default), AG<br>    charge_type = string // PREPAID, POSTPAID(default)<br>    bandwidth_limit_type = string // INTER_REGION_LIMIT, OUTER_REGION_LIMIT(default)<br>    regions = optional(list(string))<br>    bandwidth_limit = optional(number)<br>    tags = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_nat_gateways"></a> [nat\_gateways](#input\_nat\_gateways) | nat gateway | <pre>list(object({<br>    vpc_name = optional(string)<br>    nat_name = string<br>    bandwidth = optional(number)<br>    max_concurrent = optional(number)<br>    eips = map(object({<br>      internet_charge_type = optional(string)<br>      internet_max_bandwidth_out = optional(number)<br>      internet_service_provider = optional(string)<br>      bandwidth_package_id = optional(string)<br>    }))<br>    tags = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | n/a | <pre>list(object({<br>    vpc_name = optional(string)<br>    route_table_name = string<br>    dest_to_hub = optional(map(string))<br>    # 目标CIDR           下一跳<br>    # 自动根据下一跳识别下一跳类型：<br>    # 如果下一跳：<br>    #   是0，       则下一跳类型为 EIP<br>    #   是IP地址，   则下一跳类型为 NORMAL_CVM<br>    #   以pcx开头，  则下一跳类型为 PEERCONNECTION<br>    #   以dcg开头，  则下一跳类型为 DIRECTCONNECT<br>    #   以vpngw开头，则下一跳类型为 VPN<br>    attach_nat_gateway = optional(bool)<br>    nat_gateway_name = optional(string) # if attach_nat_gateway is true, this value must be set and exist in nat-gateways<br>    nat_gateway_destination_cidr_block = optional(string)<br>    attach_vpc_peerings = optional(bool)<br>    attach_dcg = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | <pre>list(object({<br>    vpc_name = optional(string)<br>    subnet_name = string<br>    subnet_cidr = string<br>    route_table_name = optional(string)<br>    availability_zone = string<br>    subnet_tags = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_vpc_peerings"></a> [vpc\_peerings](#input\_vpc\_peerings) | n/a | `list(list(string))` | `[]` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | n/a | <pre>map(object({<br>    vpc_name = string<br>    vpc_cidr = string<br>    vpc_is_multicast = optional(bool)<br>    vpc_dns_servers = optional(list(string))<br>    vpc_tags = optional(map(string))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ccns"></a> [ccns](#output\_ccns) | n/a |
| <a name="output_default_route_entries"></a> [default\_route\_entries](#output\_default\_route\_entries) | n/a |
| <a name="output_default_rtbs"></a> [default\_rtbs](#output\_default\_rtbs) | n/a |
| <a name="output_inregion_ccns"></a> [inregion\_ccns](#output\_inregion\_ccns) | n/a |
| <a name="output_nats"></a> [nats](#output\_nats) | n/a |
| <a name="output_route_entries"></a> [route\_entries](#output\_route\_entries) | n/a |
| <a name="output_rtbs"></a> [rtbs](#output\_rtbs) | n/a |
| <a name="output_subnet_azs"></a> [subnet\_azs](#output\_subnet\_azs) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
