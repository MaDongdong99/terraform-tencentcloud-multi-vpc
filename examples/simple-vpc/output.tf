output "vpc_id" {
  value = module.vpc.vpcs
}

//output "subnets" {
//  value = module.vpc.subnets
//}

output "rtbs" {
  value = module.vpc.rtbs
}

output "default_rtbs" {
  value = module.vpc.default_rtbs
}

output "nats" {
  value = module.vpc.nats
}


output "default_route_entries" {
  value = module.vpc.default_route_entries
}

output "route_entries" {
  value = module.vpc.route_entries
}
