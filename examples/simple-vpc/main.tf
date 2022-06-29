
module "vpc" {
  source = "../../"

  vpcs = {
    "test-vpc-1" = {
      vpc_name = "test-vpc-1"
      vpc_cidr = "10.250.0.0/16"
    }
    "test-vpc-2" = {
      vpc_name = "test-vpc-2"
      vpc_cidr = "10.251.0.0/16"
    }
  }

  nat_gateways = [
    {
      vpc_name = "test-vpc-1"
      nat_name = "nat-1"
      eips = [{
        internet_max_bandwidth_out = 10
        internet_service_provider = "CMCC"
      }]
    }
  ]

  default_route_tables = {
    "test-vpc-1" = {
      dest_to_hub = {
        "4.5.6.7/32": 0
      }
      attach_nat_gateway = true
      nat_gateway_name = "nat-1"
      nat_gateway_destination_cidr_block = "0.0.0.0/0"
    }
  }

  route_tables = [
    {
      vpc_name = "test-vpc-1"
      route_table_name = "rtb-1"
      dest_to_hub = {
        "1.2.3.4/32": 0
      }
      attach_nat_gateway = true
      nat_gateway_name = "nat-1" # if attach_nat_gateway is true, this value must be set and exist in nat-gateways
      nat_gateway_destination_cidr_block = "0.0.0.0/0"
    },
    {
      vpc_name = "test-vpc-2"
      route_table_name = "rtb-2"
      dest_to_hub = {
        "1.2.3.5/32": 0
      }
      attach_nat_gateway = false
//      nat_gateway_name = "nat-1" # if attach_nat_gateway is true, this value must be set and exist in nat-gateways
//      nat_gateway_destination_cidr_block = "0.0.0.0/0"
    }
  ]

  subnets = [
    {
      vpc_name = "test-vpc-1"
      subnet_name = "test-subnet-1"
      subnet_cidr = "10.250.1.0/24"
      route_table_name = ""
      availability_zone = "ap-hangzhou-ec-1"
      subnet_tags = {}
    },
    {
      vpc_name = "test-vpc-1"
      subnet_name = "test-subnet-2"
      subnet_cidr = "10.250.2.0/24"
      route_table_name = "rtb-1"
      availability_zone = "ap-hangzhou-ec-1"
      subnet_tags = {}
    }

  ]

}
