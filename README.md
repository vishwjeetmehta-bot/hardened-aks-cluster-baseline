<div align="center">

# ☸️ Hardened AKS Cluster Baseline

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.29-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Azure AKS](https://img.shields.io/badge/Azure-AKS_Hardened-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/services/kubernetes-service/)
[![Cilium CNI](https://img.shields.io/badge/Network_Plane-Cilium_eBPF-F46800?style=for-the-badge&logo=cilium&logoColor=white)](https://cilium.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](./LICENSE)

<p align="center">
  <b>Production-grade reference implementation for hardened Azure Kubernetes Service (AKS) adhering to CIS Kubernetes Benchmark, Cilium eBPF network security, Azure AD Workload Identity, and automated Trivy vulnerability scanning.</b>
</p>

</div>

---

## 🛡️ Architecture & Security Model

```
                    ┌──────────────────────────────────────────────┐
                    │ Azure AD / Entra ID Workload Identity        │
                    └──────────────────────┬───────────────────────┘
                                           │ Federated Credential (OIDC)
                                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ Azure Kubernetes Service (AKS) - Hardened Baseline                       │
│                                                                          │
│  ┌─────────────────────────┐       ┌──────────────────────────────────┐  │
│  │ System Node Pool        │       │ User Workload Node Pool          │  │
│  │ (Critical Addons Only)  │       │ (Autoscaling 2-6 Nodes)          │  │
│  │  - CoreDNS              │       │  - App Microservices (Restricted)│  │
│  │  - Azure KeyVault CSI   │       │  - Cilium L3/L4/L7 NetworkPolicy │  │
│  │  - Trivy Operator       │       │  - Non-Root ReadOnly RootFS      │  │
│  └─────────────────────────┘       └──────────────────────────────────┘  │
│                                                                          │
│   eBPF Network Data Plane: Cilium | Pod Security Standard: Restricted   │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🔒 Security Capabilities

- **Cilium eBPF CNI & Security Policies**: Native eBPF network filtering with default-deny ingress and egress policies.
- **Azure Workload Identity**: Zero static secrets in pods; uses OIDC federation directly with Azure Key Vault and Azure databases.
- **Pod Security Standards (PSS)**: Namespace-level enforcement of the `restricted` profile preventing privileged containers, host networking, and root escalation.
- **Continuous In-Cluster Vulnerability Scanning**: Aqua Trivy Operator scanning images and runtime workloads automatically for CVEs.
- **Azure Key Vault Provider for Secrets Store CSI**: Secure mTLS mount of secrets directly into memory.

---

## 📁 Repository Layout

```
hardened-aks-cluster-baseline/
├── .github/workflows/
│   └── k8s-security-ci.yml     # Kubeval manifest validation & Checkov scan
├── terraform/                  # Terraform IaC for Hardened AKS + VNet + Identities
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── kubernetes/manifests/       # Hardened namespace configs, default-deny policies
│   ├── default-deny-networkpolicy.yaml
│   ├── pod-security-standards.yaml
│   └── resource-quotas.yaml
├── helm/values/                # Production values for Ingress, Cert-Manager, Trivy
│   ├── cert-manager.yaml
│   ├── ingress-nginx.yaml
│   └── trivy-operator.yaml
└── README.md
```

---

## ⚡ Deployment Instructions

```bash
# 1. Provision Infrastructure
cd terraform
terraform init
terraform apply -auto-approve

# 2. Connect to Cluster
az aks get-credentials --resource-group sec-aks-rg --name sec-aks-cluster

# 3. Apply Hardened Policies
kubectl apply -f ../kubernetes/manifests/

# 4. Install Observability & Security Addons
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -f ../helm/values/ingress-nginx.yaml
```

---

## 👤 Author

**Vishwjeet Kumar Mehta**  
Senior DevOps & DevSecOps Consultant | Cloud & Infrastructure Architect  
- **LinkedIn**: [linkedin.com/in/vishwjeetmehta](https://linkedin.com/in/vishwjeetmehta)  
- **GitHub**: [@vishwjeetmehta-bot](https://github.com/vishwjeetmehta-bot)
