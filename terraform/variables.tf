variable "prefix" {
  description = "Resource prefix"
  type        = string
  default     = "sec-aks"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "eastus"
}

variable "kubernetes_version" {
  description = "Target hardened Kubernetes version"
  type        = string
  default     = "1.29.2"
}

variable "system_node_count" {
  description = "Number of system node pool nodes"
  type        = number
  default     = 3
}

variable "user_node_count" {
  description = "Number of user workload node pool nodes"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "VM SKU for user node pool"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "tags" {
  type = map(string)
  default = {
    Environment   = "Production"
    Architect     = "Vishwjeet Kumar Mehta"
    SecurityLevel = "Hardened-Baseline"
    ManagedBy     = "Terraform"
  }
}

