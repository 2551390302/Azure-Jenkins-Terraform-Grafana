# 原有的变量保持不变
variable "resource_group_name" {
  description = "资源组名称"
  type        = string
}

variable "location" {
  description = "Azure 区域（如果创建新 VNet 则需要）"
  type        = string
  default     = null # 当使用现有 VNet 时可忽略
}

variable "vnet_name" {
  description = "新 VNet 名称（当 create_vnet = true 时使用）"
  type        = string
  default     = null
}

variable "address_space" {
  description = "新 VNet 的地址空间（当 create_vnet = true 时需要）"
  type        = list(string)
  default     = null
}

# 新增变量
variable "create_vnet" {
  description = "是否创建新的 VNet，如果为 false 则使用现有 VNet"
  type        = bool
  default     = true
}

variable "existing_vnet_name" {
  description = "现有 VNet 名称（当 create_vnet = false 时必填）"
  type        = string
  default     = null
}

# 子网前缀变量保持不变
variable "aks_subnet_prefix" {
  description = "AKS 子网地址前缀"
  type        = list(string)
}

variable "tags" {
  description = "要应用到资源的标签"
  type        = map(string)
  default     = {}
}