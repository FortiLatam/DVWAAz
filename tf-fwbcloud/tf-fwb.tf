terraform {
  required_providers {
    fortiappseccloud = {
      source  = "fortinet/fortiappseccloud"
      version = "1.0.0"
    }
  }
}

provider "fortiappseccloud" {
  hostname   = "api.appsec.fortinet.com"
  api_token  = "<API_FWB_TOKEN>"
}

resource "fortiappseccloud_waf_app" "app_<APP_NAME>" {
  app_name    = "webapp_<APP_NAME>"
  domain_name = "<CNAME_APP>"
  app_service = {
    http  = 80
    https = 443
  }
  origin_server_ip      = "<EXTERNAL_LBIP>"
  origin_server_service = "HTTP"
  origin_server_port    = "80"
  cdn                   = false
  continent_cdn         = false
  block                 = true
}

output "cname" {
  value = fortiappseccloud_waf_app.app_<APP_NAME>.cname
}
