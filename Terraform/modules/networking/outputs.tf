output "aks_subnet_id" {
  description = "AKS 子网的资源 ID"
  value       = azurerm_subnet.aks.id
}

output "vnet_id" {
  description = "VNet 的资源 ID（新或旧）"
  value       = var.create_vnet ? azurerm_virtual_network.this[0].id : data.azurerm_virtual_network.existing[0].id
}