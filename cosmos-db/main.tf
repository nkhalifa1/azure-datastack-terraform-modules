resource "azurerm_cosmosdb_account" "syn_cosmos" {
  name                                  = "cosmos-${var.prefix}-${var.postfix}"
  location                              = var.location
  resource_group_name                   = var.rg_name
  offer_type                            = "Standard"
  kind                                  = "GlobalDocumentDB"
  network_acl_bypass_for_azure_services = false

  enable_automatic_failover     = true
  public_network_access_enabled = false

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level       = "Eventual"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }
}

# DNS Zones

resource "azurerm_private_dns_zone" "sql_zone" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.rg_name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "sql_zone_link" {
  name                  = "${var.postfix}_link_sql"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_zone.name
  virtual_network_id    = var.vnet_id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-${azurerm_cosmosdb_account.syn_cosmos.name}-sql"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-sql-psc-${var.postfix}"
    private_connection_resource_id = azurerm_cosmosdb_account.syn_cosmos.id
    subresource_names              = ["sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-sql"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_zone.id]
  }
}

# Create db

resource "azurerm_cosmosdb_sql_database" "syn_cosmosdb_sql_database" {
  name                = "cosmosdb${var.postfix}"
  resource_group_name = azurerm_cosmosdb_account.syn_cosmos.resource_group_name
  account_name        = azurerm_cosmosdb_account.syn_cosmos.name
  throughput          = 400
}