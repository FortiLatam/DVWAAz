terraform {
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
    }
  }
}

provider "fortios" {
  hostname     = "<FGT_IP>:<FGT_PORT>"
  token        = "<API_FGT_TOKEN>"
  insecure     = "true"
}

resource "fortios_firewall_address" "demoaddr" {
  color                = 3
  name                 = "<DYN_ADDR_NAME>"
  type                 = "dynamic"
  sdn                  = "<SDN_NAME>"
  filter               = "Tag.app=<TAG_NAME>"
  visibility           = "enable"
  sdn_addr_type        = "private"
}

resource "fortios_firewall_policy" "fwpolrule" {
  action                      = "accept"
  av_profile                  = "default"
  inspection_mode             = "proxy"
  ips_sensor                  = "default"
  logtraffic                  = "utm"
  name                        = "Allow <TAG_NAME> egress"
  schedule                    = "always"
  ssl_ssh_profile             = "deep-inspection"
  dlp_profile                 = "Demo-DLP"
  status                      = "enable"
  utm_status                  = "enable"
    service {
    name = "HTTP"
  }
  service {
    name = "HTTPS"
  }
  dstintf {
      name = "geneve-az1"
  }
  srcintf {
      name = "geneve-az1"
  }
  dstaddr {
    name = "all"
  }
  srcaddr {
      name = "<DYN_ADDR_NAME>"
  }
    depends_on = [fortios_firewall_address.demoaddr]
}
resource "fortios_firewall_security_policyseq" "fwpolorder" {
  policy_src_id         = fortios_firewall_policy.fwpolrule.policyid
  policy_dst_id         = 3
  alter_position        = "before"
  enable_state_checking = true
}

resource "fortios_firewall_policy" "fwpolrule2" {
  action                      = "accept"
  av_profile                  = "default"
  inspection_mode             = "proxy"
  ips_sensor                  = "default"
  logtraffic                  = "utm"
  name                        = "Allow <TAG_NAME> egress2"
  schedule                    = "always"
  ssl_ssh_profile             = "deep-inspection"
  dlp_profile                 = "Demo-DLP"
  status                      = "enable"
  utm_status                  = "enable"
    service {
    name = "HTTP"
  }
  service {
    name = "HTTPS"
  }
  dstintf {
      name = "geneve-az2"
  }
  srcintf {
      name = "geneve-az2"
  }
  dstaddr {
    name = "all"
  }
  srcaddr {
      name = "<DYN_ADDR_NAME>"
  }
    depends_on = [fortios_firewall_address.demoaddr]
}
resource "fortios_firewall_security_policyseq" "fwpolorder2" {
  policy_src_id         = fortios_firewall_policy.fwpolrule2.policyid
  policy_dst_id         = 5
  alter_position        = "before"
  enable_state_checking = true
}
