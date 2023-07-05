output "vpcs" {
  value = local.vpc_id_map
}

output "subnets" {
  value = local.subnet_name_to_id
}

output "subnet_azs" {
  value = local.subnet_name_to_az
}

output "rtbs" {
  value = local.route_table_id_map
}

output "default_rtbs" {
  value = local.default_rtb_map
}

output "nats" {
  value = local.nat_gateway_id_map
}

output "default_route_entries" {
  value = local.default_entry_map
}

output "route_entries" {
  value = local.rtb_entry_map
}

output "ccns" {
  value = local.ccn_id_map
}