provider "azurerm" {
  features {}
  subscription_id = var.main_subscription_id
  alias           = "main"
}


# 调用网络模块
module "networking" {
  source = "../../modules/networking"

  resource_group_name = "rg-kk01-eas-second-kerwin02" # VNet 所在的资源组
  existing_vnet_name  = "vnet-kk02-eas-devops02"      # 现有 VNet 名称
  aks_subnet_prefix   = ["10.0.1.0/24"]               # 新子网的地址范围
  create_vnet         = false                         # 关键：不创建新 VNet

  # 以下参数在 create_vnet = false 时不再需要，但模块允许默认值，可忽略
  # location            = null
  # vnet_name           = null
  # address_space       = null
}

# 调用 AKS 模块
module "aks" {
  source = "../../modules/aks"

  resource_group_name = "rg-kk01-eas-second-kerwin02"
  location            = "eastasia"
  cluster_name        = "aks-dev-devops01"
  dns_prefix          = "aksdevdevops01"

  # 使用最便宜的 VM 大小（B 系列，开发/测试适用）
  vm_size = "Standard_B2s" # 2 vCPU, 4 GB 内存，可运行少量容器

  # 子网 ID 必须是完整的 Azure 资源 ID，而不是仅 VNet 名称！
  # 示例：/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet-name/subnets/subnet-name
  vnet_subnet_id = "/subscriptions/5143bb9c-9dc6-46f8-b72a-e9cec9e8192a/resourceGroups/rg-kk02-eas-devops01/providers/Microsoft.Network/virtualNetworks/vnet-kk02-eas-devops01"

  # 启用自动缩放
  enable_auto_scaling = true # 允许节点池动态扩缩容
  min_nodes           = 1    # 最小节点数（节省成本）
  max_nodes           = 3    # 最大节点数（应对突发负载）

  # 限制每个节点的 Pod 数量
  max_pods = 50 # 每个节点最多运行 50 个 Pod（默认通常为 110，可根据需求降低）
}