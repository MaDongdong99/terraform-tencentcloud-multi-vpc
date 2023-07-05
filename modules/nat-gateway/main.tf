locals {
  assigned_eip_set = [ for name, eip in tencentcloud_eip.eips : eip.public_ip]
}

resource "tencentcloud_eip" "eips" {
  for_each                   = var.eips
  internet_charge_type       = each.value.internet_charge_type
  internet_max_bandwidth_out = each.value.internet_max_bandwidth_out
  type                       = "EIP"
  internet_service_provider = each.value.internet_service_provider
  tags = var.tags
}

resource "tencentcloud_nat_gateway" "nat" {
  name             = var.name
  vpc_id           = var.vpc_id
  bandwidth        = var.bandwidth
  max_concurrent   = var.max_concurrent
  assigned_eip_set = local.assigned_eip_set

  tags = var.tags
}

output "nat_name" {
  value = tencentcloud_nat_gateway.nat.name
}
output "nat_id" {
  value = tencentcloud_nat_gateway.nat.id
}