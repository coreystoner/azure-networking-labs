# Module 05: Azure Firewall

## ⚠️ Cost Warning

**Azure Firewall costs approximately $1.25–$1.50/hr.** Run `cleanup.ps1 -ModuleOnly` immediately after completing validation.

See [cost-estimate.md](./cost-estimate.md) for the full breakdown.

---

## Learning Objectives

- Deploy Azure Firewall in the hub VNet
- Create a Firewall Policy with network rules, application rules, and DNAT rules
- Understand the difference between Classic rules and Firewall Policy
- Route traffic through the firewall using UDRs (from Module 04)
- Explain the role of `AzureFirewallSubnet` and its size requirement

---

## Background: Key Concepts

### Azure Firewall Architecture

Azure Firewall is a cloud-native, stateful firewall-as-a-service. It:
- Deploys into a dedicated `AzureFirewallSubnet` (/26 minimum) in your hub VNet
- Has a public IP for internet-facing traffic
- Supports FQDN-based application rules (not just IP/port)

### Rule Types

| Rule Type | Layer | Example Use Case |
|-----------|-------|------------------|
| **Network rules** | L3/L4 | Allow SQL (1433) from app tier to data tier |
| **Application rules** | L7 (FQDN) | Allow `*.microsoft.com` HTTPS outbound |
| **DNAT rules** | Inbound NAT | Expose a VM RDP behind a public IP |

Evaluation order: DNAT → Network → Application. First match wins.

---

## Prerequisites

- Module 01 completed (hub VNet with `10.0.0.0/16`)
- Budget/credits available (~$1.50/hr)

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F05-azure-firewall%2Fdeploy.json)

Deployment takes **5–10 minutes**. You'll be taken to the Azure portal — select your subscription and resource group, then click **Review + Create**.

### ⚡ Option B — Automated Script

```powershell
.\Start-Module.ps1
```

The script shows the cost warning and asks for confirmation before proceeding.

### 🔧 Option C — Manual

```powershell
az deployment group create --resource-group rg-azure-networking-labs --template-file deploy.bicep
```

---

## What Was Deployed

| Resource | Details |
|----------|---------|
| `AzureFirewallSubnet` | Added to hub VNet, prefix `10.0.4.0/26` |
| `pip-afw-hub` | Public IP for the firewall |
| `afwp-hub` | Firewall Policy with example rules |
| `afw-hub` | Azure Firewall (Standard SKU) at `10.0.4.4` |

---

## Explore

```powershell
# Verify private IP is 10.0.4.4
az network firewall show \
  --resource-group rg-azure-networking-labs \
  --name afw-hub \
  --query 'ipConfigurations[0].privateIPAddress'
```

---

## Validate

```powershell
.\validate.ps1
```

## ⚠️ Clean Up Immediately After Validating

```powershell
.\cleanup.ps1 -ModuleOnly
```

---

## Next Up

**Module 06: Fault Lab — NSG** — A misconfigured NSG is blocking traffic. Can you find and fix it?
