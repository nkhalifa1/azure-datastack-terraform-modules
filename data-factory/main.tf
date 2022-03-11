resource "azurerm_data_factory" "syn_adf" {
  name                = "adf-${var.prefix}-${var.postfix}"
  location            = var.location
  resource_group_name = var.rg_name

  public_network_enabled          = false
  managed_virtual_network_enabled = true
}

# DNS Zones

resource "azurerm_private_dns_zone" "df_zone" {
  name                = "privatelink.datafactory.azure.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone" "portal_zone" {
  name                = "privatelink.adf.azure.com"
  resource_group_name = var.rg_name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "df_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_df"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.df_zone.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "portal_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_portal"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.portal_zone.name
  virtual_network_id    = var.vnet_id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "df_pe" {
  name                = "pe-${azurerm_data_factory.syn_adf.name}-df"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-df-psc-${var.postfix}"
    private_connection_resource_id = azurerm_data_factory.syn_adf.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-df"
    private_dns_zone_ids = [azurerm_private_dns_zone.df_zone.id]
  }
}

resource "azurerm_private_endpoint" "portal_pe" {
  name                = "pe-${azurerm_data_factory.syn_adf.name}-portal"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-portal-psc-${var.postfix}"
    private_connection_resource_id = azurerm_data_factory.syn_adf.id
    subresource_names              = ["portal"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-portal"
    private_dns_zone_ids = [azurerm_private_dns_zone.portal_zone.id]
  }
}