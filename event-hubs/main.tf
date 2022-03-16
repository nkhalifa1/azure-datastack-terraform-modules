resource "azurerm_eventhub_namespace" "syn_evhns" {
  name                     = "evhns-${var.prefix}-${var.postfix}"
  location                 = var.location
  resource_group_name      = var.rg_name
  sku                      = "Standard"
  maximum_throughput_units = 20
  zone_redundant           = true
  auto_inflate_enabled     = true

  network_rulesets {
    default_action = "Deny"
    # trusted_service_access_enabled = false
    # virtual_network_rule           = []
    # ip_rule                        = []
  }
}

# DNS Zones

resource "azurerm_private_dns_zone" "evhns_zone" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.rg_name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "evhns_zone_link" {
  name                  = "${var.prefix}${var.postfix}_link_evhns"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.evhns_zone.name
  virtual_network_id    = var.vnet_id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "evhns_pe" {
  name                = "pe-${azurerm_eventhub_namespace.syn_evhns.name}-evhns"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-evhnspsc-${var.postfix}"
    private_connection_resource_id = azurerm_eventhub_namespace.syn_evhns.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-evhns"
    private_dns_zone_ids = [azurerm_private_dns_zone.evhns_zone.id]
  }
}