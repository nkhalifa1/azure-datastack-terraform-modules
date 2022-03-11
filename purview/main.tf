resource "azurerm_purview_account" "syn_pview" {
  name                = "pview-${var.prefix}-${var.postfix}"
  resource_group_name = var.rg_name
  location            = var.location

  public_network_enabled      = false
  managed_resource_group_name = "${var.rg_name}-pview-managed"
}

# DNS Zones

resource "azurerm_private_dns_zone" "purview_zone" {
  name                = "privatelink.purview.azure.com"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone" "studio_zone" {
  name                = "privatelink.purviewstudio.azure.com"
  resource_group_name = var.rg_name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "purview_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_purview"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.purview_zone.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "studio_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_studio"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.studio_zone.name
  virtual_network_id    = var.vnet_id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "purview_pe" {
  name                = "pe-${azurerm_purview_account.syn_pview.name}-purview"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-purview-psc-${var.postfix}"
    private_connection_resource_id = azurerm_purview_account.syn_pview.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-purview"
    private_dns_zone_ids = [azurerm_private_dns_zone.purview_zone.id]
  }
}

resource "azurerm_private_endpoint" "studio_pe" {
  name                = "pe-${azurerm_purview_account.syn_pview.name}-studio"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-studio-psc-${var.postfix}"
    private_connection_resource_id = azurerm_purview_account.syn_pview.id
    subresource_names              = ["portal"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-studio"
    private_dns_zone_ids = [azurerm_private_dns_zone.purview_zone.id]
  }
}