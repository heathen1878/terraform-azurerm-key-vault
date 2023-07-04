output "key_vault" {
    value = {
        id = azurerm_key_vault.key_vault.id
        vault_uri = azurerm_key_vault.key_vault.vault_uri
    }
}