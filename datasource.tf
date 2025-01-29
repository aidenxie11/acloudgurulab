# data "azurerm_resource_group" "rgds" {
#   name = azurerm_resource_group.myrg.name
# }

# data "azurerm_virtual_network" "vnetds" {
#   name                = azurerm_virtual_network.myvnet.name
#   resource_group_name = azurerm_resource_group.myrg.name
# }

# data "azurerm_subscription" "current" {
# }
 
# output "ds_rg_name" {
#   value = data.azurerm_resource_group.rgds.name
# }

# output "ds_rg_id" {
#   value = data.azurerm_resource_group.rgds.id
# }

# output "ds_rg_location" {
#   value = data.azurerm_resource_group.rgds.location
# }

# output "ds_vnet_name" {
#   value = data.azurerm_virtual_network.vnetds.name
  
# }



# output "ds_vnet_id" {
#   value = data.azurerm_virtual_network.vnetds.id
# }

# output "ds_vnet_location" {
#   value = data.azurerm_virtual_network.vnetds.location
# }

# output "ds_vnet_address_space" {
#   value = data.azurerm_virtual_network.vnetds.address_space
# }

# output "current_subscription_dispalyname" {
#   value = data.azurerm_subscription.current.display_name
  
# }

# output "current_subscription_id" {
#   value = data.azurerm_subscription.current.subscription_id
  
# }

# output "current_subscription_spending_limt" {
#   value = data.azurerm_subscription.current.spending_limit
  
# }
