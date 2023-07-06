
locals {
  # global
  tags = var.tags

  # vpc
  vpc_id_map = { for name, vpc in tencentcloud_vpc.vpcs: name => vpc.id }
  vpc_multicast_map = { for name, vpc in tencentcloud_vpc.vpcs: name => vpc.is_multicast }
  vpc_cidr_map = { for name, vpc in tencentcloud_vpc.vpcs: name => vpc.cidr_block }

  # nat gateway
  eips = flatten([
    for nat in var.nat_gateways: [
      for eip_name, eip in nat.eips: {
        k = format("%s.%s.%s", nat.vpc_name, nat.nat_name, eip_name)
        internet_charge_type = eip.internet_charge_type
        internet_max_bandwidth_out = eip.internet_max_bandwidth_out
        internet_service_provider = eip.internet_service_provider
      }
    ]
  ])
  eip_map = { for eip in local.eips : eip.k => eip }
  nat_gateway_eips = { for nat in var.nat_gateways: format("%s.%s", nat.vpc_name, nat.nat_name) => [ for eip_name, eip in nat.eips: format("%s.%s.%s", nat.vpc_name, nat.nat_name, eip_name) ]  }
  nat_gateway_eip_ips = { for nat_name, eip_names in local.nat_gateway_eips: nat_name => [ for eip_name in eip_names: tencentcloud_eip.eips[eip_name].public_ip ]  }
  nat_gateways = { for nat in var.nat_gateways: format("%s.%s", nat.vpc_name, nat.nat_name) => nat }
  nat_gateway_id_map = { for key, nat in tencentcloud_nat_gateway.nat: key => nat.id }

  # default route table
  default_rtb_map = { for vpc_name, default_rtb in data.tencentcloud_vpc_route_tables.default_rtbs:  format("%s.default", vpc_name) => default_rtb.instance_list[0].route_table_id }

  # route tables
  route_tables = { for rtb in var.route_tables: format("%s.%s", rtb.vpc_name, rtb.route_table_name) => rtb }
  route_table_id_map = { for key, rtb in tencentcloud_route_table.rtbs: key => rtb.id }

  # route table entries
  rtb_pfx_to_next_type = {
    "pcx" : "PEERCONNECTION",
    "dcg" : "DIRECTCONNECT",
    "vpngw" : "VPN",
    "nat" : "NAT",
    "0" : "EIP",
    "ccn": "CCN",
  }
  rtb_entry_list = concat(
    flatten([
      for rtb in var.route_tables: [
        for destination_cidr_block, next_hub in rtb.dest_to_hub: {
          entry_key = format("%s.%s.%s", rtb.vpc_name, rtb.route_table_name, destination_cidr_block)
          vpc_id = local.vpc_id_map[rtb.vpc_name]
          destination_cidr_block = destination_cidr_block
          next_hub = next_hub
          route_table_id = local.route_table_id_map[format("%s.%s", rtb.vpc_name, rtb.route_table_name)]
        }
      ]
    ]),
    flatten([
      for rtb in var.route_tables: {
        entry_key = format("%s.%s.nat", rtb.vpc_name, rtb.route_table_name)
        vpc_id = local.vpc_id_map[rtb.vpc_name]
        route_table_id = local.route_table_id_map[format("%s.%s", rtb.vpc_name, rtb.route_table_name)]
        destination_cidr_block = rtb.nat_gateway_destination_cidr_block
        next_hub = local.nat_gateway_id_map[format("%s.%s", rtb.vpc_name, rtb.nat_gateway_name)]
      } if rtb.attach_nat_gateway
    ]),
    flatten([
      for peer in var.vpc_peerings: [
        for rtb in var.route_tables: {
          entry_key = format("%s.%s.peer.%s", peer[0], rtb.route_table_name, peer[2])
          vpc_id = local.vpc_id_map[peer[0]]
          route_table_id = local.route_table_id_map[format("%s.%s", rtb.vpc_name, rtb.route_table_name)]
          destination_cidr_block = lookup(local.vpc_cidr_map, peer[1], peer[1])
          next_hub = peer[2]
        } if rtb.attach_vpc_peerings && peer[0] == rtb.vpc_name
      ]
    ])
  )
  rtb_entry_map = { for entry in local.rtb_entry_list: entry.entry_key => entry }
  default_rtb_entry_list = concat(
    flatten([
      for vpc_name, default_rtb in var.default_route_tables: [
        for destination_cidr_block, next_hub in default_rtb.dest_to_hub: {
          entry_key = format("%s.default.%s", vpc_name, destination_cidr_block)
          vpc_id = local.vpc_id_map[vpc_name]
          route_table_id = local.default_rtb_map[format("%s.default", vpc_name)]
          destination_cidr_block = destination_cidr_block
          next_hub = next_hub
        }
      ]
    ]),
    flatten([
      for vpc_name, default_rtb in var.default_route_tables: {
        entry_key = format("%s.default.nat", vpc_name)
        vpc_id = local.vpc_id_map[vpc_name]
        route_table_id = local.default_rtb_map[format("%s.default", vpc_name)]
        destination_cidr_block = default_rtb.nat_gateway_destination_cidr_block
        next_hub = local.nat_gateway_id_map[format("%s.%s", vpc_name, default_rtb.nat_gateway_name)]
      } if default_rtb.attach_nat_gateway
    ]),
    flatten([
      for peer in var.vpc_peerings: {
        entry_key = format("%s.default.peer.%s", peer[0], peer[2])
        vpc_id = local.vpc_id_map[peer[0]]
        route_table_id = local.default_rtb_map[format("%s.default", peer[0])]
        destination_cidr_block = lookup(local.vpc_cidr_map, peer[1], peer[1])
        next_hub = peer[2]
      } if var.default_route_tables[peer[0]].attach_vpc_peerings
    ])
  )
  default_entry_map = { for entry in local.default_rtb_entry_list: entry.entry_key => entry }

  # subnet
  subnets = { for subnet in var.subnets : format("%s.%s", subnet.vpc_name, subnet.subnet_name) => subnet }
//  created_subnets = { for name, subnet in module.subnet: name => subnet.subnet }
  subnet_name_to_id = { for key, subnet in tencentcloud_subnet.subnets: key => subnet.id }
  subnet_name_to_az = { for key, subnet in tencentcloud_subnet.subnets: key => subnet.availability_zone }

  # ccn
  ccn_attachments_list = flatten([
    for name, vpcs in var.ccn_attachments: [
      for vpc in vpcs: {
        key = format("%s.%s", name, vpc.vpc_name)
        ccn_id = lookup(local.ccn_id_map, name, name)
        ccn_name = name
        vpc_name = vpc.vpc_name
        vpc_id = vpc.vpc_id
        vpc_region = vpc.vpc_region
        ccn_uin = vpc.ccn_uin
      }
    ]
  ])
  ccn_attachments = {for att in local.ccn_attachments_list: att.key => att }
  ccn_region_limits_list = flatten([
    for name, ccn in var.ccns: [
      for region in ccn.regions: {
        key = format("%s.%s", name, region)
        ccn_id = local.ccn_id_map[name]
        region = region
        bandwidth_limit = ccn.bandwidth_limit
      }
    ]
  ])
  ccn_region_limits = {for limit in local.ccn_region_limits_list: limit.key => limit }
  ccn_id_map = { for name, ccn in tencentcloud_ccn.ccns: name => ccn.id }
}

# VPC
resource "tencentcloud_vpc" "vpcs" {
  for_each     = var.vpcs
  name         = each.key
  cidr_block   = each.value.vpc_cidr
  is_multicast = each.value.vpc_is_multicast == null ? false : each.value.vpc_is_multicast
  dns_servers  = each.value.vpc_dns_servers
  tags         = merge(var.tags, each.value.vpc_tags)
}


# Nat Gateway
resource "tencentcloud_eip" "eips" {
  for_each                   = local.eip_map
  internet_charge_type       = each.value.internet_charge_type
  internet_max_bandwidth_out = each.value.internet_max_bandwidth_out
  type                       = "EIP"
  internet_service_provider = each.value.internet_service_provider
  tags = var.tags
}

resource "tencentcloud_nat_gateway" "nat" {
  for_each = local.nat_gateways
  name             = each.value.nat_name
  vpc_id           = local.vpc_id_map[each.value.vpc_name]
  bandwidth        = each.value.bandwidth
  max_concurrent   = each.value.max_concurrent
  assigned_eip_set = local.nat_gateway_eip_ips[format("%s.%s", each.value.vpc_name, each.value.nat_name)]

  tags = var.tags
}

//module "nats" {
//  for_each = local.nat_gateways
//  source = "./modules/nat-gateway"
//
//  vpc_id = local.vpc_id_map[each.value.vpc_name]
//  name = each.value.nat_name
//  bandwidth = each.value.bandwidth
//  max_concurrent = each.value.max_concurrent
//  eips = each.value.eips
//  tags = merge(var.tags, each.value.tags)
//}

# route tables
resource "tencentcloud_route_table" "rtbs" {
  for_each = local.route_tables
  name   = each.value.route_table_name
  vpc_id = local.vpc_id_map[each.value.vpc_name]
}

data "tencentcloud_vpc_route_tables" "default_rtbs" {
  for_each = local.vpc_id_map
  vpc_id = each.value
  name = "default"
}

# route table entries
resource "tencentcloud_route_table_entry" "entries" {
//  count = length(local.rtb_entry_list)
  for_each = local.rtb_entry_map
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  next_type              = can(cidrnetmask(format("%s/%s", each.value.next_hub, "32"))) ?  "NORMAL_CVM" : local.rtb_pfx_to_next_type[split("-", each.value.next_hub)[0]]
  next_hub               = each.value.next_hub
}

resource "tencentcloud_route_table_entry" "defaults" {
//  count = length(local.default_rtb_entry_list)
  for_each = local.default_entry_map
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  next_type              = can(cidrnetmask(format("%s/%s", each.value.next_hub, "32"))) ?  "NORMAL_CVM" : local.rtb_pfx_to_next_type[split("-", each.value.next_hub)[0]]
  next_hub               = each.value.next_hub
}

# subnets
resource "tencentcloud_subnet" "subnets" {
  for_each = local.subnets
  name              = each.value.subnet_name
  vpc_id            = local.vpc_id_map[each.value.vpc_name]
  cidr_block        = each.value.subnet_cidr
  availability_zone = each.value.availability_zone
  route_table_id    = each.value.route_table_name == null || each.value.route_table_name == "" || each.value.route_table_name == "default" ? null: local.route_table_id_map[format("%s.%s", each.value.vpc_name, each.value.route_table_name)]
  is_multicast      = local.vpc_multicast_map[each.value.vpc_name]
  tags = merge(var.tags, each.value.subnet_tags)
}

# ccns
resource "tencentcloud_ccn" "ccns" {
  for_each = var.ccns
  name                 = each.key
  description          = each.value.description
  qos                  = each.value.qos
  charge_type          = each.value.charge_type
  bandwidth_limit_type = each.value.bandwidth_limit_type
  tags = each.value.tags
}

resource "tencentcloud_ccn_attachment" "ccn_attachment" {
  for_each = local.ccn_attachments
  ccn_id          = each.value.ccn_id
  instance_type   = "VPC"
  instance_id     = each.value.vpc_id
  instance_region = each.value.vpc_region
  ccn_uin = each.value.ccn_uin
}

resource "tencentcloud_ccn_bandwidth_limit" "ccn_limit" {
  for_each = local.ccn_region_limits
  ccn_id          = each.value.ccn_id
  region          = each.value.region
  bandwidth_limit = each.value.bandwidth_limit
}