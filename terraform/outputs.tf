output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.hardened_aks.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.hardened_aks.id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.hardened_aks.oidc_issuer_url
}

