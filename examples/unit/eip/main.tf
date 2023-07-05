resource "tencentcloud_eip" "foo" {
  name = "unit_test_ip"
  internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"
  internet_max_bandwidth_out = 500
  internet_service_provider = "BGP"
  type = "EIP"
}

data "tencentcloud_eips" "foo" {
  eip_id = tencentcloud_eip.foo.id
}

output "eip" {
  value = data.tencentcloud_eips.foo
}