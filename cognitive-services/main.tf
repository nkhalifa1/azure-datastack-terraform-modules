data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "azurerm_cognitive_account" "syn_cog" {
  name                = "cog-${var.prefix}-${var.postfix}"
  location            = var.location
  resource_group_name = var.rg_name
  kind                = var.kind

  sku_name              = "S0"
  custom_subdomain_name = "cog-${var.prefix}-${var.postfix}"

  public_network_access_enabled     = true
  outbound_network_access_restrited = false

  #   network_acls {
  #       default_action = "Deny"
  #       ip_rules = [data.http.ip.body]
  #       virtual_network_rules = []
  #   }

}

# DNS Zones

resource "azurerm_private_dns_zone" "cog_zone" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = var.rg_name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "cog_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_cog"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.cog_zone.name
  virtual_network_id    = var.vnet_id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "cog_pe" {
  name                = "pe-${azurerm_cognitive_account.syn_cog.name}-cog"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-cog-psc-${var.postfix}"
    private_connection_resource_id = azurerm_cognitive_account.syn_cog.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-cog"
    private_dns_zone_ids = [azurerm_private_dns_zone.cog_zone.id]
  }
}