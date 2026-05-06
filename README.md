# 🚀 Deploying Azure 3-Tier Web App with Terraform, Docker & GitHub Actions

> **Fully automated CI/CD pipeline** — every `git push` builds a Docker image, provisions Azure infrastructure with Terraform, and deploys a containerised Flask app onto two Linux VMs behind an Azure Load Balancer.
>
> This is an **exact Azure port** of the original AWS project. Every AWS service has a direct Azure equivalent — see the mapping table below.

---

## 🔁 AWS → Azure Service Mapping

| AWS | Azure | Purpose |
|-----|-------|---------|
| VPC | Virtual Network (VNet) | Private network |
| Internet Gateway | Built-in VNet routing | Internet access for public subnets |
| Elastic IP | Public IP (Static, Standard SKU) | Fixed public IPs |
| NAT Gateway | NAT Gateway | Outbound internet for private subnets |
| Subnets | Subnets | Network segmentation |
| Route Tables | Route Tables / NSG associations | Traffic routing |
| Security Groups | Network Security Groups (NSG) | Firewall rules |
| EC2 (Amazon Linux 2) | Azure Linux VM (Ubuntu 22.04 LTS) | Compute |
| Key Pair | SSH public key on VM | SSH access |
| Application Load Balancer | Azure Standard Load Balancer | Traffic distribution |
| ALB Target Group | LB Backend Pool | VM registration |
| ALB Listener | LB Rule | Port 80 forwarding |
| ALB Health Check | LB Probe (HTTP, path=/) | Instance health |
| ECR (Container Registry) | ACR (Azure Container Registry) | Docker image storage |
| S3 + DynamoDB (TF state) | Azure Blob Storage (built-in locking) | Terraform remote state |
| IAM Access Keys | Azure Service Principal (AZURE_CREDENTIALS) | CI/CD auth |

---

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Prerequisites](#-prerequisites)
- [Setup & Deployment](#-setup--deployment)
- [GitHub Secrets Reference](#-github-secrets-reference)
- [Terraform Outputs](#-terraform-outputs)
- [Destroying Resources](#-destroying-resources)

---

## 🏛️ Architecture

### Network Layout — VNet: `10.0.0.0/16` (Region: `westeurope`)

| Subnet | CIDR | Purpose |
|--------|------|---------|
| `public-subnet-1` | `10.0.1.0/24` | LB frontend + Bastion VM |
| `public-subnet-2` | `10.0.2.0/24` | LB frontend (second zone) |
| `private-app-subnet-1` | `10.0.3.0/24` | App VM 1 |
| `private-app-subnet-2` | `10.0.4.0/24` | App VM 2 |
| `private-db-subnet-1` | `10.0.5.0/24` | Reserved (Azure Database / Redis) |
| `private-db-subnet-2` | `10.0.6.0/24` | Reserved (Azure Database / Redis) |

### NSG Rules

| NSG | Inbound | Notes |
|-----|---------|-------|
| `lb-nsg` | `* → TCP 80` | Public HTTP |
| `bastion-nsg` | `* → TCP 22` | SSH management |
| `instance-nsg` | `public-subnet → 80`, `public-subnet → 22` | No direct internet |
| `db-nsg` | `VNet CIDR → 3306, 6379` | DB/Redis — internal only |

### CI/CD Pipeline

```
git push
    │
    ├─► 1. Build & Push Docker Image  ──► Azure ACR (tagged with commit SHA)
    │
    ├─► 2. Terraform Apply            ──► Provisions all Azure infrastructure
    │
    └─► 3. Ansible Provision          ──► Installs Docker, pulls & runs container
                                          on both private app VMs via Bastion
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Application** | Python · Flask 2.2.2 |
| **Containerisation** | Docker (python:3.11.1-slim-buster) |
| **Container Registry** | Azure Container Registry (ACR) |
| **Infrastructure (IaC)** | Terraform (AzureRM provider ~> 3.0) |
| **Provisioning** | Ansible |
| **CI/CD** | GitHub Actions |
| **State Management** | Azure Blob Storage (built-in lease locking) |
| **Compute** | Azure Linux VM Standard_B1s × 3 (2 app + 1 bastion) |
| **Load Balancing** | Azure Standard Load Balancer |
| **Networking** | VNet · NSG · NAT Gateway · Public IPs |

---

## 📁 Repository Structure

```
.
├── Monty_Hall_Game_Flask_App/        # Unchanged from original — no cloud deps
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── static/
│   └── templates/
│
├── Terraform/
│   ├── main.tf                       # Root — wires all modules
│   ├── provider.tf                   # AzureRM provider config
│   ├── backend.tf                    # Remote state (Azure Blob Storage)
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── output.tf
│   └── Modules/
│       ├── VNet/                     # VNet · subnets · NAT Gateway
│       ├── NSG/                      # All 4 NSGs + subnet associations
│       ├── VM/                       # 3 Linux VMs + NICs + LB pool association
│       └── LB/                       # Azure LB · backend pool · probe · rule
│
├── ansible/
│   ├── ansible.cfg
│   └── docker_playbook.yml           # Install Docker · pull ACR image · run container
│
└── .github/
    └── workflows/
        └── deploy.yml                # Full CI/CD pipeline
```

---

## ✅ Prerequisites

Before running the pipeline, ensure the following exist in Azure:

- [ ] **Resource Group** for Terraform state: `tfstate-rg`
- [ ] **Storage Account** named `tfstateformonty` (must be globally unique — change if taken)
- [ ] **Blob Container** named `tfstate` inside the storage account
- [ ] **Azure Container Registry (ACR)** — enable Admin user in Access Keys settings
- [ ] **Azure Service Principal** with Contributor role on your subscription
- [ ] All GitHub Secrets configured (see table below)

### Create the Terraform state backend (run once manually):

```bash
az group create --name tfstate-rg --location westeurope
az storage account create --name tfstateformonty --resource-group tfstate-rg --sku Standard_LRS
az storage container create --name tfstate --account-name tfstateformonty
```

### Create ACR:

```bash
az acr create --name montyhallacr --resource-group monty-hall-rg --sku Basic --admin-enabled true
# Get credentials:
az acr credential show --name montyhallacr
```

### Create Service Principal:

```bash
az ad sp create-for-rbac \
  --name "monty-hall-sp" \
  --role Contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
  --sdk-auth
# Copy the entire JSON output → paste as AZURE_CREDENTIALS secret
```

---

## 🔐 GitHub Secrets Reference

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description | AWS Equivalent |
|--------|-------------|----------------|
| `AZURE_CREDENTIALS` | Full JSON from `az ad sp create-for-rbac --sdk-auth` | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` |
| `ACR_LOGIN_SERVER` | e.g. `montyhallacr.azurecr.io` | ECR registry URL |
| `ACR_USERNAME` | ACR admin username | — |
| `ACR_PASSWORD` | ACR admin password | — |
| `VM_SSH_PUBLIC_KEY` | Contents of your `~/.ssh/id_rsa.pub` | `EC2_PUBLIC_SSH_KEY` |
| `VM_SSH_PRIVATE_KEY` | Contents of your `~/.ssh/id_rsa` | `EC2_PRIVATE_SSH_KEY` |

---

## 🚀 Setup & Deployment

### 1. Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f ssh_key_azure   # press Enter twice for no passphrase
chmod 400 ssh_key_azure

cat ssh_key_azure        # → paste into GitHub Secret: VM_SSH_PRIVATE_KEY
cat ssh_key_azure.pub    # → paste into GitHub Secret: VM_SSH_PUBLIC_KEY
```

### 2. Add GitHub Secrets

Add all 6 secrets from the table above.

### 3. Trigger the Pipeline

Push any commit to `main`, or go to **Actions** tab → select the workflow → click **Run workflow**.

### 4. Access the App

Once the pipeline completes, go to **Azure Portal → Load Balancers → monty-hall-lb → Frontend IP** and open the IP in your browser (or check the GitHub Actions logs — the final step prints the URL).

---

## 📤 Terraform Outputs

| Output | Description |
|--------|-------------|
| `lb_public_ip` | Paste into browser to reach the app |
| `bastion_public_ip` | SSH into bastion to access private VMs |
| `vnet_id` | ID of the created VNet |
| `nat_gateway_public_ip` | Public IP of the NAT Gateway |

---

## ⚠️ Destroying Resources

> **This project uses paid Azure services.** NAT Gateways, VMs, and Load Balancers accrue hourly charges. **Always destroy resources when finished.**

**Option A — via GitHub Actions (recommended):**
Go to **Actions** → select the workflow → **Run workflow** → choose `destroy`.

**Option B — manual:**
```bash
az group delete --name monty-hall-rg --yes --no-wait
```

---

## 📝 Variable Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `location` | `westeurope` | Azure deployment region |
| `resource_group_name` | `monty-hall-rg` | Resource group for all resources |
| `vnet_cidr` | `10.0.0.0/16` | VNet CIDR block |
| `vm_size` | `Standard_B1s` | VM size (~t3.micro equivalent) |
| `admin_username` | `azureuser` | SSH admin user on all VMs |
| `lb_name` | `monty-hall-lb` | Load balancer resource name |

---

<div align="center">
  <sub>Azure port of the original AWS project by ENSiGN-CODES</sub>
</div>
