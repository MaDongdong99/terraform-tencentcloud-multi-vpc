terraform {
  required_version = ">=1.0.9"
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">=1.60.22"
    }
  }
}
