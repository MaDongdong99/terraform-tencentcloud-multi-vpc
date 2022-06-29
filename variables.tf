variable "vpcs" {
  type = map(object({
    vpc_name = string
    vpc_cidr = string
    vpc_is_multicast = optional(bool)
    vpc_dns_servers = optional(list(string))
    vpc_tags = optional(map(string))
  }))
  default = {}
}

variable subnets {
  type = list(object({
    vpc_name = string
    subnet_name = string
    subnet_cidr = string
    route_table_name = optional(string)
    availability_zone = string
    subnet_tags = optional(map(string))
  }))
  default = []
}

# route table
variable "default_route_tables" {
  type = map(object({
    dest_to_hub = optional(map(string))
    attach_nat_gateway = optional(bool)
    nat_gateway_name = optional(string)
    nat_gateway_destination_cidr_block = optional(string)
    # 目标CIDR           下一跳
    # 自动根据下一跳识别下一跳类型：
    # 如果下一跳：
    #   是0，       则下一跳类型为 EIP
    #   是IP地址，   则下一跳类型为 NORMAL_CVM
    #   以pcx开头，  则下一跳类型为 PEERCONNECTION
    #   以dcg开头，  则下一跳类型为 DIRECTCONNECT
    #   以vpngw开头，则下一跳类型为 VPN
  }))
  default = {}
}

variable route_tables {
  type = list(object({
    vpc_name = string
    route_table_name = string
    dest_to_hub = map(string)
    # 目标CIDR           下一跳
    # 自动根据下一跳识别下一跳类型：
    # 如果下一跳：
    #   是0，       则下一跳类型为 EIP
    #   是IP地址，   则下一跳类型为 NORMAL_CVM
    #   以pcx开头，  则下一跳类型为 PEERCONNECTION
    #   以dcg开头，  则下一跳类型为 DIRECTCONNECT
    #   以vpngw开头，则下一跳类型为 VPN
    attach_nat_gateway = optional(bool)
    nat_gateway_name = optional(string) # if attach_nat_gateway is true, this value must be set and exist in nat-gateways
    nat_gateway_destination_cidr_block = optional(string)
  }))
  default = []
}

# nat gateway
variable nat_gateways {
  type = list(object({
    vpc_name = string
    nat_name = string
    bandwidth = optional(number)
    max_concurrent = optional(number)
    eips = list(object({
      internet_charge_type = optional(string)
      internet_max_bandwidth_out = optional(number)
      internet_service_provider = optional(string)
    }))
    tags = optional(map(string))
  }))
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}