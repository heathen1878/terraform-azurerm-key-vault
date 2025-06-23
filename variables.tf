variable "name" {
  description = "Key Vault Name"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "The Key Vault name must be lowercase and between 3 and 24 characters in length"
  }
}

variable "location" {
  description = "Key Vault location"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+(?:[23])?$", var.location))
    error_message = "The location must be a lowercase and constructed using letters a-z; can have an optional number appended too."
  }
}

variable "resource_group_name" {
  description = "Key Vault resource group"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._()\\-]*[^.]$", var.resource_group_name))
    error_message = "The resource group name must start with a number or letter, and can consist of letters, numbers, underscores, periods, parentheses and hyphens but must not end in a period."
  }
}

variable "tenant_id" {
  description = "AAD Tenant associated with the Key Vault; used with rbac"
  type        = string
  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-([a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}$", var.tenant_id))
    error_message = "The tenant id must be a valid GUID"
  }
}

variable "sku_name" {
  description = "Key Vault Sku"
  default     = "standard"
  type        = string
  validation {
    condition = contains(
      [
        "standard",
        "premium"
      ], var.sku_name
    )
    error_message = "The Sku options are: Standard or Premium"
  }
}

variable "contacts" {
  description = "A map of contacts"
  default     = {}
  type = map(object(
    {
      email = string
      name  = optional(string)
      phone = optional(string)
    }
  ))
  validation {
    condition = alltrue([
      for key, value in var.contacts : (
        can(regex("^.+@.+\\..+$", value.email)) && (value.phone == null || can(regex("^[0-9]{10,}$", value.phone)))
      )
    ])
    error_message = "Each contact must have a valid email address and phone number of provided."
  }
}

variable "enabled_for_deployment" {
  description = "Can Azure Virtual machine retrieve certificates from this Key Vaults?"
  default     = false
  type        = bool
  validation {
    condition     = contains([true, false], var.enabled_for_deployment)
    error_message = "Can only be be true or false."
  }
}

variable "enabled_for_disk_encryption" {
  description = "Can Azure Disk Encryption retrieve secrets from this Key Vault and unwrap secret keys?"
  default     = false
  type        = bool
  validation {
    condition     = contains([true, false], var.enabled_for_disk_encryption)
    error_message = "Can only be be true or false."
  }
}

variable "enabled_for_template_deployment" {
  description = "Can Azure Resource Manager retrieve secrets from this Key Vault?"
  default     = false
  type        = bool
  validation {
    condition     = contains([true, false], var.enabled_for_template_deployment)
    error_message = "Can only be be true or false."
  }
}

variable "private_endpoint" {
  description = "Should this Key Vault be assigned a Private Endpoint?"
  default     = {}
  type = map(object(
    {
      name                            = string
      location                        = string
      resource_group_name             = string
      subnet_id                       = string
      custom_network_interface_name   = string
      private_service_connection_name = string
      private_dns_zone_ids            = list(string)
    }
  ))
}

variable "enable_rbac_authorization" {
  description = "Does this Key Vault use RBAC authorisation for Data Actions?"
  default     = true
  type        = bool
  validation {
    condition     = contains([true, false], var.enable_rbac_authorization)
    error_message = "Can only be be true or false."
  }
}

variable "network_acls" {
  description = "A map of Acl configuration"
  default     = {}
  type = object(
    {
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }
  )
}

variable "purge_protection_enabled" {
  description = "Should purge protection be enabled? - a word of warning this cannot be disabled, though the Key Vault can be deleted it will be recoverable for ~90 days."
  default     = true
  type        = bool
  validation {
    condition     = contains([true, false], var.purge_protection_enabled)
    error_message = "Can only be be true or false."
  }
}

variable "public_network_access_enabled" {
  description = "Should this Key Vault be publicly accessible? - false for private endpoint only - true if used with network acls"
  default     = true
  type        = bool
  validation {
    condition     = contains([true, false], var.public_network_access_enabled)
    error_message = "Can only be be true or false."
  }
}

variable "soft_delete_retention_days" {
  description = "Retention of deleted certificates, keys and secrets - IMPORTANT this can only be set once!"
  default     = 7
  type        = number
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention days must be between 7 and 90"
  }
}

variable "tags" {
  description = "A map of tags"
  default = {
    "warning" = "No tagging applied"
  }
  type = map(any)
  validation {
    condition     = alltrue([for v in values(var.tags) : can(regex(".*", v))])
    error_message = "All values in the map must be strings"
  }
}

variable "workstream_service_principal" {
  description = "The service principal associated with the workstream"
  default     = null
  type        = string
  validation {
    condition     = var.workstream_service_principal == null || can(regex("^[a-fA-F0-9]{8}-([a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}$", var.workstream_service_principal))
    error_message = "The principal id must be a GUID"
  }
}

variable "iams" {
  description = "A map of IAM"
  default     = {}
  type = map(object(
    {
      name                             = optional(string)
      role_definition_name             = string
      principal_id                     = string
      principal_type                   = optional(string)
      description                      = optional(string)
      skip_service_principal_aad_check = optional(bool, false)
  }))
}

variable "diagnostic_settings" {
  description = "A map of objects with diagnostic configuration"
  default     = {}
  type = map(object({
    name                           = string
    target_sub_resource            = string
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    logs                           = optional(list(string))
    log_category                   = optional(list(string))
    metrics                        = optional(list(string))
    storage_account_id             = optional(string)
  }))
}