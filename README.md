# Azure Networking Labs 🌐

A self-paced, gamified learning series for IT pros and sysadmins building Azure networking skills from the ground up.

## How It Works

1. Open [**the learning portal**](./portal/index.html) in your browser (clone the repo first)
2. Start **Module 01** — it's always available
3. Deploy resources using the provided Bicep template
4. Run `validate.ps1` to check your work — it outputs an **unlock code** on success
5. Enter the unlock code in the portal to mark the module complete and unlock the next one
6. Run `cleanup.ps1` when you're done (or to save money between sessions)

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`) — recommended
- An Azure subscription (free trial works for Modules 01–04)
- Windows PowerShell 5.1+ or PowerShell 7+
- Basic IP networking knowledge (subnets, CIDR) — not Azure-specific knowledge required

## Module Overview

| # | Module | Topics | Est. Cost |
|---|--------|---------|:---------:|
| [01](./modules/01-vnets-subnets/) | VNets & Subnets | Address spaces, CIDR, subnet design | ~$0.00/hr ✅ |
| [02](./modules/02-nsgs/) | Network Security Groups | Rules, priorities, default rules | ~$0.00/hr ✅ |
| [03](./modules/03-peering/) | VNet Peering | Hub-spoke topology, peering states | ~$0.00/hr ✅ |
| [04](./modules/04-routing-udrs/) | Routing & UDRs | Route tables, next-hop types | ~$0.00/hr ✅ |
| [05](./modules/05-azure-firewall/) | Azure Firewall | Firewall policies, DNAT, app rules | ~$1.50/hr ⚠️ |
| [06](./modules/06-fault-nsg/) | Fault Lab: NSG | Find & fix a broken NSG config | ~$0.10/hr 🔧 |
| [07](./modules/07-fault-routing/) | Fault Lab: Routing | Find & fix a broken route table | ~$0.10/hr 🔧 |

> ⚠️ **Cost Note:** Modules 01–04 deploy only VNets, subnets, NSGs, and route tables — these are **free** in Azure. Module 05 deploys an Azure Firewall (~$1.50/hr). Fault labs (06–07) deploy small VMs (~$0.10/hr). Each module includes a detailed cost estimate and a cleanup script.

## Quick Start

```powershell
# 1. Clone the repo
git clone https://github.com/coreystoner/azure-networking-labs.git
cd azure-networking-labs

# 2. Log in to Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# 3. Create the shared resource group (used by all modules)
az group create --name rg-azure-networking-labs --location eastus

# 4. Open the learning portal in your browser
# On Windows:
Start-Process portal/index.html

# 5. Deploy Module 01
cd modules/01-vnets-subnets
az deployment group create --resource-group rg-azure-networking-labs --template-file deploy.bicep
```

## Cleanup Everything

Each module has a `cleanup.ps1`. To remove **all** lab resources at once:

```powershell
az group delete --name rg-azure-networking-labs --yes --no-wait
```

## Resetting Progress

Progress is stored in your browser's localStorage. To reset:
1. Open the portal in your browser
2. Open DevTools (F12) → Console
3. Run: `localStorage.removeItem('anlProgress'); location.reload()`

---

*Built for the Azure community. Not an official Microsoft product.*
