# 如果需要创建新 VNet，则创建它
resource "azurerm_virtual_network" "this" {
  count = var.create_vnet ? 1 : 0

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

# 如果使用现有 VNet，则通过数据源引用它
data "azurerm_virtual_network" "existing" {
  count = var.create_vnet ? 0 : 1

  name                = var.existing_vnet_name
  resource_group_name = var.resource_group_name
}

# 本地变量，简化后续对 VNet 名称的引用
locals {
  vnet_name = var.create_vnet ? azurerm_virtual_network.this[0].name : data.azurerm_virtual_network.existing[0].name
}

# 始终创建子网（无论 VNet 是新是旧）
resource "azurerm_subnet" "aks" {
  name                 = "subnet-aks-devops01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = var.aks_subnet_prefix
}