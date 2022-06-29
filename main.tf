
locals {
  # global
  tags = var.tags

  # vpc
  vpc_id_map = { for name, vpc in tencentcloud_vpc.vpcs: name => vpc.id }
  vpc_multicast_map = { for name, vpc in tencentcloud_vpc.vpcs: name => vpc.is_multicast }

  # nat gateway
  nat_gateways = { for nat in var.nat_gateways: format("%s.%s", nat.vpc_name, nat.nat_name) => nat }
  nat_gateway_id_map = { for key, nat in module.nats: key => nat.nat_id }

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
    ])
  )
  default_entry_map = { for entry in local.default_rtb_entry_list: entry.entry_key => entry }

  # subnet
  subnets = { for subnet in var.subnets : format("%s.%s", subnet.vpc_name, subnet.subnet_name) => subnet }
//  created_subnets = { for name, subnet in module.subnet: name => subnet.subnet }
  subnet_name_to_id = { for key, subnet in tencentcloud_subnet.subnets: key => subnet.id }

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
module "nats" {
  for_each = local.nat_gateways
  source = "./modules/nat-gateway"

  vpc_id = local.vpc_id_map[each.value.vpc_name]
  name = each.value.nat_name
  bandwidth = each.value.bandwidth
  max_concurrent = each.value.max_concurrent
  eips = each.value.eips
  tags = merge(var.tags, each.value.tags)
}

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
