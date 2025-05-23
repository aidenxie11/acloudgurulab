variable "azure_subscription_id" {
  default = "2213e8b1-dbc7-4d54-8aff-b5e315df5e5b"

}
variable "resource_group_name" {
  default     = "1-a8ede6ed-playground-sandbox"
  description = "Resource group name"
  type        = string
}

variable "location" {
  default     = "South Central US"
  description = "Resource group location"
  type        = string
  validation {
    # condition = var.location == "eastus" || var.location == "South Central US"
    # condition = contains(["eastus", "South Central US"], var.location)
    condition     = can(regex("US$", var.location))
    error_message = "We only allow resources to be created in eastus or South Central US"
  }
}

variable "business_unit" {
  default     = "playground"
  description = "Business unit name"
  type        = string
}

variable "environment" {
  default     = "sandbox"
  description = "Environment name"
  type        = string

}

variable "virtual_network_name" {
  default     = "myvnet"
  description = "Virtual network name"
  type        = string

}

variable "subnet_name" {
  default     = "mysubnet"
  description = "Subnet name"
  type        = string

}

variable "virtual_network_address_space" {
  default     = ["10.0.0.0/16", "10.1.0.0/16", "10.1.0.0/16"]
  description = "Virtual network address space"
  type        = list(string)
}

variable "public_ip_sku" {
  description = "Azure Public IP Address SKU"
  type        = map(string)
  default = {
    "eastus"           = "Basic",
    "South Central US" = "Standard"
  }
}

variable "common_tags" {
  description = "Common Tags for Azure Resources"
  type        = map(string)
  default = {
    "CLITool" = "Terraform",
    "Tag1"    = "Azure"
    "Tag2"    = "RemoteState"
  }

}

# variable "db_name" {
#   description = "Azure MySQL Database DB Name"
#   type = string
# }

# variable "db_username" {
#   description = "sql username"
#   type = string
#   sensitive = true
# }

# variable "db_password" {
#   description = "sql password"
#   type = string
#   sensitive = true
# }

# variable "db_storage_mb" {
#   description = "sql db storage in MB"
# }

# variable "db_auto_grow_enabled" {
#   description = "sql db - enable or disable Auto Grow Feature"
#   type = bool
# }