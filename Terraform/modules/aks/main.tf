resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = var.enable_auto_scaling ? null : var.node_count # 启用自动缩放时，node_count 不能设置
    vm_size        = var.vm_size
    vnet_subnet_id = var.vnet_subnet_id

    # 自动缩放相关
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_nodes : null
    max_count           = var.enable_auto_scaling ? var.max_nodes : null

    # 每个节点的最大 Pod 数
    max_pods = var.max_pods
  }

  identity {
    type = "SystemAssigned"
  }

  # 其他配置（如网络插件等）可根据需要添加
  network_profile {
    network_plugin = "azure" # 使用 Azure CNI
    network_policy = "azure" # 可选
  }

  role_based_access_control_enabled = true
}