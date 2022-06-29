resource "tencentcloud_vpc" "foo" {
  name         = "ci-temp-test-updated"
  cidr_block   = "10.0.0.0/16"
  dns_servers  = ["119.29.29.29", "8.8.8.8"]
  is_multicast = false

  tags = {
    "test" = "test"
  }
}