resource "azurerm_key_vault" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  tags                            = var.tags

  network_acls {
    bypass                     = var.network_acls.bypass
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      contact # managed by azurerm_key_vault_certificate_contacts.this
    ]
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "azurerm_role_assignment" "contact" {
  for_each = length(var.contacts) != 0 ? { "create_contacts" = "true" } : {}

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = var.workstream_service_principal

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "azurerm_key_vault_certificate_contacts" "this" {
  for_each = length(var.contacts) != 0 ? { "create_contacts" = "true" } : {}

  key_vault_id = azurerm_key_vault.this.id

  dynamic "contact" {
    for_each = var.contacts

    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  depends_on = [
    azurerm_role_assignment.this
  ]
}

resource "azurerm_private_endpoint" "key_vault" {
  for_each = var.private_endpoint

  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name

  private_service_connection {
    name                           = each.value.private_service_connection_name
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = each.value.private_dns_zone_ids
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = var.iams

  name                             = each.value.name
  scope                            = azurerm_key_vault.this.id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = each.value.principal_id
  principal_type                   = each.value.principal_type
  description                      = each.value.description
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}

module "diagnostics" {
  for_each = var.diagnostic_settings

  source  = "heathen1878/diagnostic-logging/azurerm"
  version = "1.0.0"

  name                           = each.value.name
  target_resource_id             = azurerm_key_vault.this.id
  eventhub_name                  = each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs                           = each.value.logs
  log_category                   = each.value.log_category
  metrics                        = each.value.metrics
  storage_account_id             = each.value.storage_account_id
}