resource "azurerm_key_vault" "key_vault" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  enable_rbac_authorization = var.enable_rbac_authorization

  network_acls {
    bypass                     = var.network_acls.bypass
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }

  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  soft_delete_retention_days = var.soft_delete_retention_days

  tags = var.tags

}

resource "azurerm_private_endpoint" "key_vault" {
  for_each = var.enable_private_endpoint == true ? { "Private Endpoint" = "True" } : {}

  name                          = format("pep-%s", var.name)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.virtual_network_subnet_private_endpoint_id
  custom_network_interface_name = format("nic-%s", var.name)

  private_service_connection {
    name                           = format("pl-%s", var.name)
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags

}

resource "azurerm_role_assignment" "key_vault" {
  for_each = var.iam

  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

}