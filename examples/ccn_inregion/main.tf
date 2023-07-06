

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

  inregion_ccns = {
    "test-ccn-1": {
      ccn_name = "test-ccn-1"
      description = "test-ccn-1"
      qos = "AU" // PT, AU(default), AG
      charge_type = "POSTPAID" // PREPAID, POSTPAID(default)
      bandwidth_limit_type = "OUTER_REGION_LIMIT" // INTER_REGION_LIMIT, OUTER_REGION_LIMIT(default)
      regions = ["ap-guangzhou"]
      bandwidth_limit = 100
      tags = {}
    }
  }
  inregion_ccn_attachments = {
    "test-ccn-1": [
      {
        vpc_name = "test-vpc-1"
        vpc_region = "ap-guangzhou"
      },
      {
        vpc_name = "test-vpc-2"
        vpc_region = "ap-guangzhou"
      },
    ]
  }

}
