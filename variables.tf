variable "name" {
  description = "Key Vault Name"
  type        = string
}

variable "location" {
  description = "Key Vault location"
  type        = string
}

variable "resource_group_name" {
  description = "Key Vault ressource group"
  type        = string
}

variable "tenant_id" {
  description = "AAD Tenant associated with the Key Vault; used with rbac"
  type        = string
}

variable "sku_name" {
  description = "Key Vault Sku"
  type        = string
}

variable "enabled_for_deployment" {
  description = "Can Azure Virtual machine retrieve certificates from this Key Vaults?"
  default     = false
  type        = bool
}

variable "enabled_for_disk_encryption" {
  description = "Can Azure Disk Encryption retrieve secrets from this Key Vault and unwrap secret keys?"
  default     = false
  type        = bool
}

variable "enabled_for_template_deployment" {
  description = "Can Azure Resource Manager retrieve secrets from this Key Vault?"
  default     = false
  type        = bool
}

variable "enable_private_endpoint" {
  description = "Should this Key Vault be assigned a Private Endpoint?"
  type        = bool
}

variable "enable_rbac_authorization" {
  description = "Does this Key Vault use RBAC authorisation for Data Actions?"
  default     = false
  type        = bool
}

variable "iam" {
  description = "A map of RBAC assignments"
  default     = {}
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
}

variable "network_acls" {
  description = "A map of Acl configuration"
  type = object({
    bypass                     = optional(string, "None")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
}

variable "private_dns_zone_ids" {
  description = "A list of Private DNS zone to integrate with Private Endpoint"
  default     = []
  type        = list(string)
}

variable "purge_protection_enabled" {
  description = "Should purge protection be enabled? - a word of warning this cannot be disabled, though the Key Vault can be deleted it will be recoverable for ~90 days."
  default     = false
  type        = bool
}

variable "public_network_access_enabled" {
  description = "Should this Key Vault be publicaly accessible?"
  type        = bool
}

variable "soft_delete_retention_days" {
  description = "Retention of deleted certificates, keys and secrets"
  type        = number
}

variable "tags" {
  description = "A map of tags"
  type        = map(any)
}

variable "virtual_network_subnet_private_endpoint_id" {
  description = "The subnet associated with the Private Endpoint"
  default     = ""
  type        = string
}