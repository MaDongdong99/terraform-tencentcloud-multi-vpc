

module "vpc" {
  source = "../../"

  ccn_attachments = {
    "ccn-12345678": [
      {
        vpc_name = "vpc-12345678"
        vpc_id = "vpc-12345678"
        vpc_region = "ap-guangzhou"
        ccn_uin = 1234567890
      },
    ]
  }

}
