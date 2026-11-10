terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.240.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-nodes-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.240.0.0/20"]
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.prefix}-controlplane-id"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "hardened_aks" {
  name                = "${var.prefix}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.prefix}-k8s"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "systempool"
    node_count          = var.system_node_count
    vm_size             = "Standard_D2s_v5"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    type                = "VirtualMachineScaleSets"
    os_sku              = "Ubuntu"
    only_critical_addons_enabled = true
    enable_auto_scaling = false
    tags                = var.tags
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    dns_service_ip      = "10.0.0.10"
    service_cidr        = "10.0.0.0/16"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  private_cluster_enabled   = false

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "workloads" {
  name                  = "workloadpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.hardened_aks.id
  vm_size               = var.vm_size
  node_count            = var.user_node_count
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
  mode                  = "User"
  os_sku                = "Ubuntu"
  enable_auto_scaling   = true
  min_count             = 2
  max_count             = 6
  tags                  = var.tags
}

