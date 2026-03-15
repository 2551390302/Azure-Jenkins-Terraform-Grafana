variable "resource_group_name" {
  description = "资源组名称"
  type        = string
}

variable "location" {
  description = "Azure 区域"
  type        = string
}

variable "cluster_name" {
  description = "AKS 集群名称"
  type        = string
}

variable "dns_prefix" {
  description = "集群 DNS 前缀"
  type        = string
}

variable "vm_size" {
  description = "节点池的 VM 大小"
  type        = string
}

variable "vnet_subnet_id" {
  description = "子网 ID，用于 AKS 集群的网络"
  type        = string
}

# 自动缩放相关变量
variable "enable_auto_scaling" {
  description = "是否启用节点池自动缩放"
  type        = bool
  default     = false
}

variable "min_nodes" {
  description = "最小节点数"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "最大节点数"
  type        = number
  default     = 1
}

variable "max_pods" {
  description = "每个节点的最大 Pod 数"
  type        = number
  default     = 30
}

variable "existing_vnet_name" {
  description = "现有 VNet 名称（当 create_vnet = false 时必填）"
  type        = string
  default     = "vnet-kk02-eas-devops01"
}

variable "tags" {
  description = "要应用到资源的标签"
  type        = map(string)
  default     = {}
}