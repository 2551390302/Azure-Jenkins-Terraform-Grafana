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

    # 新增 Kubernetes provider
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    # 新增 Helm provider
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

  }
}

provider "azurerm" {
  features {}
  subscription_id = var.main_subscription_id
}

# 配置 Kubernetes provider（使用本地 kubeconfig）
provider "kubernetes" {
  config_path = "~/.kube/config" # 使用默认路径，如果你修改过请相应调整
}

# 配置 Helm provider（复用 Kubernetes provider 的连接）
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


# 固定时间资源
resource "time_static" "this" {} # 新增资源

locals {
  resource_group_name = "rg-kk02-eas-devops01"
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

  resource_group_name = local.resource_group_name
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

  resource_group_name = local.resource_group_name
  location            = "eastasia"
  cluster_name        = "aks-dev-devops01"
  dns_prefix          = "aksdevdevops01"
  kubernetes_version  = "1.33.7"

  # 使用最便宜的 VM 大小（B 系列，开发/测试适用）
  vm_size         = "Standard_E2s_v3"
  os_disk_size_gb = 30

  # 子网 ID 必须是完整的 Azure 资源 ID，而不是仅 VNet 名称！
  # 示例：/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet-name/subnets/subnet-name
  vnet_subnet_id = module.networking.aks_subnet_id # 引用网络模块输出的子网 ID

  # 启用自动缩放
  enable_auto_scaling = true # 允许节点池动态扩缩容
  min_nodes           = 1    # 最小节点数（节省成本）
  max_nodes           = 2    # 最大节点数（应对突发负载）

  # 限制每个节点的 Pod 数量
  max_pods = 50 # 每个节点最多运行 50 个 Pod（默认通常为 30，可根据需求降低）

  zones = []

  tags = merge(local.common_tags, {
    ServerOwner = "Kerwin Li"
  })
}

# 创建 monitoring 命名空间
  resource "kubernetes_namespace" "monitoring" {
    metadata {
      name = "nsp-d-devops01-monitoring"
    }

    # 确保 AKS 集群已准备就绪后再创建
    depends_on = [
      module.aks
    ]
  }

  # 使用 Helm 部署 kube-prometheus-stack
  resource "helm_release" "prometheus_stack" {
    name       = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    namespace  = kubernetes_namespace.monitoring.metadata[0].name

    # 可选：自定义 values，例如设置 Grafana 密码、持久化等
    # set {
    #   name  = "grafana.adminPassword"
    #   value = "your-secure-password"
    # }

    # 可以在这里添加更多自定义配置，例如指定存储类
    # values = [
    #   <<-EOT
    #   prometheus:
    #     prometheusSpec:
    #       storageSpec:
    #         volumeClaimTemplate:
    #           spec:
    #             storageClassName: managed-premium
    #             accessModes: ["ReadWriteOnce"]
    #             resources:
    #               requests:
    #                 storage: 50Gi
    #   EOT
    # ]

    depends_on = [
      kubernetes_namespace.monitoring
    ]
  }