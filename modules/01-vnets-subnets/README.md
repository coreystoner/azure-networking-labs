# Module 01: VNets & Subnets

## Learning Objectives

By the end of this module you will be able to:

- Explain what an Azure Virtual Network (VNet) is and why address space planning matters
- Create a VNet with a custom address space using Bicep
- Segment a VNet into subnets for different workload tiers
- Describe how Azure reserves IP addresses within each subnet
- Follow Azure naming conventions for network resources

---

## Background: Key Concepts

### Virtual Networks (VNets)

An Azure VNet is a logically isolated network in the cloud. It's the fundamental building block of Azure networking — similar to a traditional on-premises LAN, but software-defined. Resources within a VNet can communicate with each other by default, but are isolated from other VNets and the internet unless you explicitly configure connectivity.

### Address Spaces and CIDR Notation

Every VNet has an **address space** — a range of private IP addresses expressed in CIDR notation (e.g., `10.0.0.0/16`).

| CIDR | Addresses | Usable* |
|------|-----------|--------|
| /16 | 65,536 | 65,531 |
| /24 | 256 | 251 |
| /26 | 64 | 59 |
| /28 | 16 | 11 |

*Azure reserves 5 addresses per subnet: network address, first usable (default gateway), next two (DNS), and broadcast.

### Subnets

Subnets divide a VNet's address space into smaller segments. Best practice is to segment by workload tier:

- **Web tier** (`snet-web`) — load balancers, public-facing resources
- **App tier** (`snet-app`) — business logic, backend services
- **Data tier** (`snet-data`) — databases, caches

This separation makes it easy to apply different NSG rules (Module 02) to each tier.

---

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- An Azure subscription

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F01-vnets-subnets%2Fdeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/></a>

You'll be taken to the Azure portal — select your subscription and resource group, then click **Review + Create**.

### ⚡ Option B — Automated Script (Easiest for CLI)

```powershell
# From the module folder:
.\Start-Module.ps1

# Or from the repo root:
.\Start-Lab.ps1 -Module 01
```

This handles login, resource group creation, deployment, and offers to run validation automatically.

### 🔧 Option C — Manual

```powershell
az login
az group create --name rg-azure-networking-labs --location eastus
az deployment group create --resource-group rg-azure-networking-labs --template-file deploy.bicep
```

---

## What Was Deployed

| Resource | Name | Address Space |
|----------|------|---------------|
| Virtual Network | `vnet-hub` | `10.0.0.0/16` |
| Subnet (web) | `snet-web` | `10.0.1.0/24` |
| Subnet (app) | `snet-app` | `10.0.2.0/24` |
| Subnet (data) | `snet-data` | `10.0.3.0/24` |

---

## Explore

```powershell
az network vnet subnet list \
  --resource-group rg-azure-networking-labs \
  --vnet-name vnet-hub --output table
```

**Think about it:** If you needed a fourth subnet for a management jumpbox, what CIDR block would you use from the remaining `10.0.0.0/16` space?

---

## Validate

```powershell
.\validate.ps1
```

If all checks pass, the script will output your **unlock code**. Copy it and enter it in the learning portal to complete this module.

---

## Cleanup

```powershell
.\cleanup.ps1
```

---

## Next Up

**Module 02: Network Security Groups** — Add traffic control to your subnets with inbound and outbound security rules.
