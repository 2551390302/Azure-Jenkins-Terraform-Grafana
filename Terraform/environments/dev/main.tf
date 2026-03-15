terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    time = { # 新增 time provider
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.main_subscription_id
}

# 固定时间资源
resource "time_static" "this" {} # 新增资源

locals {
  common_tags = {
    ApplicationOwner = "Kerwin Li" # 可改为变量
    ApplicationName  = "devops-demo"
    Environment      = "dev"
    CreatedAt        = formatdate("YYYY-MM-DD hh:mm:ss", time_static.this.rfc3339)
  }
}


# 调用网络模块
module "networking" {
  source = "../../modules/networking"

  resource_group_name = "rg-kk02-eas-devops01"
  location            = "eastasia"               # 指定区域
  existing_vnet_name  = "vnet-kk02-eas-devops01" # 新 VNet 名称
  #  address_space       = ["172.16.0.0/16"]          # VNet 地址空间
  aks_subnet_prefix = ["172.16.1.0/24"] # 子网地址前缀
  create_vnet       = false             # 创建新 VNet

  tags = local.common_tags
}

# 调用 AKS 模块
module "aks" {
  source = "../../modules/aks"

  resource_group_name = "rg-kk02-eas-devops01"
  location            = "eastasia"
  cluster_name        = "aks-dev-devops01"
  dns_prefix          = "aksdevdevops01"

  # 使用最便宜的 VM 大小（B 系列，开发/测试适用）
  vm_size = "Standard_B2s" # 2 vCPU, 4 GB 内存，可运行少量容器

  # 子网 ID 必须是完整的 Azure 资源 ID，而不是仅 VNet 名称！
  # 示例：/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet-name/subnets/subnet-name
  vnet_subnet_id = module.networking.aks_subnet_id # 引用网络模块输出的子网 ID

  # 启用自动缩放
  enable_auto_scaling = true # 允许节点池动态扩缩容
  min_nodes           = 1    # 最小节点数（节省成本）
  max_nodes           = 2    # 最大节点数（应对突发负载）

  # 限制每个节点的 Pod 数量
  max_pods = 50 # 每个节点最多运行 50 个 Pod（默认通常为 30，可根据需求降低）

  tags = merge(local.common_tags, {
    ServerOwner = "Kerwin Li"
  })
}