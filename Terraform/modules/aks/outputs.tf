output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}