# https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-vnet-gateway

data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "azurerm_analysis_services_server" "syn_as" {
  name                    = "as${var.prefix}${var.postfix}"
  location                = var.location
  resource_group_name     = var.rg_name
  sku                     = "S0"
  admin_users             = var.admin_users
  enable_power_bi_service = true

  ipv4_firewall_rule {
    name        = "AllowMyPublicIp"
    range_start = data.http.ip.body
    range_end   = data.http.ip.body
  }
}
