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
- Rules apply to **all connections through that subnet or NIC**, not just existing ones
- NSGs are **stateful**: return traffic for allowed connections is automatically permitted

### Default Rules (Cannot Be Deleted)

Every NSG contains these at the bottom (high priority numbers, evaluated last):

| Name | Priority | Direction | Source | Dest | Action |
|------|----------|-----------|--------|------|--------|
| AllowVnetInBound | 65000 | Inbound | VirtualNetwork | VirtualNetwork | Allow |
| AllowAzureLoadBalancerInBound | 65001 | Inbound | AzureLoadBalancer | * | Allow |
| DenyAllInBound | 65500 | Inbound | * | * | Deny |
| AllowVnetOutBound | 65000 | Outbound | VirtualNetwork | VirtualNetwork | Allow |
| AllowInternetOutBound | 65001 | Outbound | * | Internet | Allow |
| DenyAllOutBound | 65500 | Outbound | * | * | Deny |

### Subnet vs NIC Association

- **Subnet NSG** — applies to all traffic entering/leaving the subnet
- **NIC NSG** — applies to traffic at the individual VM interface
- When both are present, **both** are evaluated (subnet NSG first for inbound, NIC NSG first for outbound)

---

## Prerequisites

- Module 01 completed (hub VNet with three subnets deployed)

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F02-nsgs%2Fdeploy.json)

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

This creates a **tiered security model**: the internet can only reach the web tier, the web tier can only reach the app tier, and the app tier can only reach the data tier.

---

## Explore

```powershell
# List all rules on nsg-web (including default rules)
az network nsg rule list \
  --resource-group rg-azure-networking-labs \
  --nsg-name nsg-web \
  --include-default \
  --output table
```

**Think about it:** The default `DenyAllInBound` rule at priority 65500 blocks everything not explicitly allowed. Why doesn't this break inter-VNet traffic between subnets? Look at the `AllowVnetInBound` rule at priority 65000.

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 03: VNet Peering** — Connect your hub VNet to a new spoke VNet and explore hub-and-spoke topology.
