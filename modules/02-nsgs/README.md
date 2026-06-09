# Module 02: Network Security Groups

## Learning Objectives

- Explain how NSG rules are evaluated (priority order, stateful matching)
- Create NSGs with appropriate inbound/outbound rules for each subnet tier
- Associate an NSG with a subnet
- Identify and explain the built-in default rules you cannot delete
- Use **Effective Security Rules** to diagnose traffic filtering

---

## Background: Key Concepts

### What Is an NSG?

A Network Security Group is a layer-4 firewall (TCP/UDP, IP) attached to a subnet or NIC. It contains ordered security rules that either **Allow** or **Deny** traffic.

### Rule Evaluation

- Rules are evaluated **lowest priority number first** (100 is evaluated before 200)
- The first matching rule wins — evaluation stops
- NSGs are **stateful**: return traffic for allowed connections is automatically permitted

### Default Rules (Cannot Be Deleted)

| Name | Priority | Direction | Action |
|------|----------|-----------|--------|
| AllowVnetInBound | 65000 | Inbound | Allow |
| AllowAzureLoadBalancerInBound | 65001 | Inbound | Allow |
| DenyAllInBound | 65500 | Inbound | Deny |
| AllowVnetOutBound | 65000 | Outbound | Allow |
| AllowInternetOutBound | 65001 | Outbound | Allow |
| DenyAllOutBound | 65500 | Outbound | Deny |

---

## Prerequisites

- Module 01 completed (hub VNet with three subnets deployed)

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F02-nsgs%2Fdeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/></a>

You'll be taken to the Azure portal — select your subscription and resource group, then click **Review + Create**.

### ⚡ Option B — Automated Script

```powershell
.\Start-Module.ps1
```

### 🔧 Option C — Manual

```powershell
az deployment group create --resource-group rg-azure-networking-labs --template-file deploy.bicep
```

---

## What Was Deployed

| NSG | Subnet | Key Rules |
|-----|--------|-----------|
| `nsg-web` | `snet-web` | Allow HTTP (80) + HTTPS (443) inbound from Internet |
| `nsg-app` | `snet-app` | Allow traffic from `snet-web` only (10.0.1.0/24) |
| `nsg-data` | `snet-data` | Allow traffic from `snet-app` only (10.0.2.0/24) |

---

## Explore

```powershell
az network nsg rule list \
  --resource-group rg-azure-networking-labs \
  --nsg-name nsg-web --include-default --output table
```

**Think about it:** Why doesn't `DenyAllInBound` at priority 65500 break inter-subnet traffic? Look at `AllowVnetInBound` at priority 65000.

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 03: VNet Peering** — Connect your hub VNet to a new spoke VNet and explore hub-and-spoke topology.
