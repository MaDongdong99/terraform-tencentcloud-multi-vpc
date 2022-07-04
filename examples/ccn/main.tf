

module "vpc" {
  source = "../../"

  ccns = {
    "test-ccn-1": {
      ccn_name = "test-ccn-1"
      description = "test-ccn-1"
      qos = "AU" // PT, AU(default), AG
      charge_type = "POSTPAID" // PREPAID, POSTPAID(default)
      bandwidth_limit_type = "OUTER_REGION_LIMIT" // INTER_REGION_LIMIT, OUTER_REGION_LIMIT(default)
      regions = ["ap-guangzhou", "ap-nanjing"]
      bandwidth_limit = 100
      tags = {}
    },
    "test-ccn-2": {
      ccn_name = "test-ccn-2"
      description = "test-ccn-2"
      qos = "AU" // PT, AU(default), AG
      charge_type = "POSTPAID" // PREPAID, POSTPAID(default)
      bandwidth_limit_type = "OUTER_REGION_LIMIT" // INTER_REGION_LIMIT, OUTER_REGION_LIMIT(default)
      regions = ["ap-guangzhou", "ap-nanjing"]
      bandwidth_limit = 100
      tags = {}
    }
  }
  ccn_attachments = {
    "test-ccn-1": [
      {
        vpc_name = "vpc-3aa7i3q9"
        vpc_id = "vpc-3aa7i3q9"
        vpc_region = "ap-guangzhou"
        ccn_uin = null
      },
      {
        vpc_name = "vpc-oy6q9oab"
        vpc_id = "vpc-oy6q9oab"
        vpc_region = "ap-nanjing"
        ccn_uin = null
      },
    ]
  }

}
