provider "azurerm" {
  features {}
  subscription_id = var.main_subscription_id
  alias           = "main"
}

# 创建资源组
resource "azurerm_resource_group" "main" {
  name     = "rg-dev-myapp"
  location = "East US"
}

# 调用网络模块
module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = "vnet-dev-myapp"
  address_space       = ["10.0.0.0/16"]
  aks_subnet_prefix   = ["10.0.1.0/24"]
}

# 调用 AKS 模块
module "aks" {
  source = "../../modules/aks"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  cluster_name        = "aks-dev-myapp"
  dns_prefix          = "aksdevmyapp"
  node_count          = 1
  vm_size             = "Standard_DS2_v2"
  vnet_subnet_id      = module.networking.aks_subnet_id
}