

module "vpc" {
  source = "../../"
  vpcs = {
    "test-vpc-1ttttt" = {
      vpc_name = "test-vpc-1"
      vpc_cidr = "10.250.0.0/16"
    }
  }

  nat_gateways = [
    {
      vpc_name = "test-vpc-1ttttt"
      nat_name = "nat-1"
      bandwidth=100,
      max_concurrent=1000000
      eips = {
        "eip1": {
          internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"
          internet_max_bandwidth_out = 100
          internet_service_provider = "BGP"
        },
        "eip2": {
          internet_max_bandwidth_out = 158
          internet_service_provider = "BGP"
          bandwidth_package_id = "bwp-gm19rlk4"
        }
      }

    }
  ]

}
