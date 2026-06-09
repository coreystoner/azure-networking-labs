# Azure Networking Labs 🌐

A self-paced, gamified learning series for IT pros and sysadmins building Azure networking skills from the ground up.

## How It Works

1. Open [**the learning portal**](./portal/index.html) in your browser (clone the repo first)
2. Start **Module 01** — it's always available
3. Deploy resources using the one-click button **or** the automated script
4. Run `validate.ps1` to check your work — it outputs an **unlock code** on success
5. Enter the unlock code in the portal to mark the module complete and unlock the next one
6. Run `cleanup.ps1` when you're done (or to save money between sessions)

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`) — recommended
- An Azure subscription (free trial works for Modules 01–04)
- Windows PowerShell 5.1+ or PowerShell 7+
- Basic IP networking knowledge (subnets, CIDR) — not Azure-specific knowledge required

## Module Overview

| # | Module | Topics | Est. Cost | Deploy |
|---|--------|---------|:---------:|:------:|
| [01](./modules/01-vnets-subnets/) | VNets & Subnets | Address spaces, CIDR, subnet design | ~$0.00/hr ✅ | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F01-vnets-subnets%2Fdeploy.bicep) |
| [02](./modules/02-nsgs/) | Network Security Groups | Rules, priorities, default rules | ~$0.00/hr ✅ | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F02-nsgs%2Fdeploy.bicep) |
| [03](./modules/03-peering/) | VNet Peering | Hub-spoke topology, peering states | ~$0.00/hr ✅ | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F03-peering%2Fdeploy.bicep) |
| [04](./modules/04-routing-udrs/) | Routing & UDRs | Route tables, next-hop types | ~$0.00/hr ✅ | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F04-routing-udrs%2Fdeploy.bicep) |
| [05](./modules/05-azure-firewall/) | Azure Firewall | Firewall policies, DNAT, app rules | ~$1.50/hr ⚠️ | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F05-azure-firewall%2Fdeploy.bicep) |
| [06](./modules/06-fault-nsg/) | Fault Lab: NSG | Find & fix a broken NSG config | ~$0.00/hr 🔧 | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F06-fault-nsg%2Fdeploy.bicep) |
| [07](./modules/07-fault-routing/) | Fault Lab: Routing | Find & fix a broken route table | ~$0.00/hr 🔧 | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F07-fault-routing%2Fdeploy.bicep) |

> ⚠️ **Cost Note:** Modules 01–04 and 06–07 deploy only VNets, subnets, NSGs, and route tables — these are **free** in Azure. Module 05 deploys an Azure Firewall (~$1.50/hr) and should be cleaned up promptly. Each module includes a detailed cost estimate and a cleanup script.

---

## Deployment Options

### Option A — One-click (Deploy to Azure button)

Click the **Deploy to Azure** button in the table above. You'll be taken directly to the Azure portal custom deployment page — log in, select your subscription and resource group, and click **Review + Create**.

### Option B — Automated Script (Recommended for beginners)

A single script handles login, resource group creation, deployment, and validation:

```powershell
# 1. Clone the repo
git clone https://github.com/coreystoner/azure-networking-labs.git
cd azure-networking-labs

# 2. Run the guided start script (handles everything interactively)
.\Start-Lab.ps1

# Or deploy a specific module directly:
.\Start-Lab.ps1 -Module 01
```

The script will:
- ✅ Check Azure CLI is installed
- ✅ Detect or prompt for Azure login
- ✅ Let you select or create the resource group
- ✅ Deploy the Bicep template with progress output
- ✅ Offer to run validation immediately after

### Option C — Manual (Full control)

```powershell
az login
az group create --name rg-azure-networking-labs --location eastus
cd modules/01-vnets-subnets
az deployment group create --resource-group rg-azure-networking-labs --template-file deploy.bicep
.\validate.ps1
```

---

## Learning Portal

Open [portal/index.html](./portal/index.html) locally in your browser to track module progress. It shows locked/unlocked/completed module cards and accepts unlock codes from `validate.ps1`.

---

## Cleanup Everything

Each module has a `cleanup.ps1`. To remove **all** lab resources at once:

```powershell
az group delete --name rg-azure-networking-labs --yes --no-wait
```

## Resetting Progress

```javascript
// In browser DevTools console (F12):
localStorage.removeItem('anlProgress'); location.reload()
```

---

*Built for the Azure community. Not an official Microsoft product.*
