# Module 04: Routing & User Defined Routes (UDRs)

[![Deploy to Azure](https://aka.ms/deploytoazure)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F04-routing-udrs%2Fdeploy.bicep)

## Learning Objectives

- Describe Azure system routes and when they are created automatically
- Create a route table with custom User Defined Routes (UDRs)
- Explain next-hop types (`Internet`, `VirtualAppliance`, `VnetLocal`, `None`)
- Associate a route table with a subnet
- Understand how UDRs override system routes
- Explain BGP route propagation and when to disable it

---

## Background: Key Concepts

### Azure System Routes

| Destination | Next Hop | Notes |
|-------------|----------|-------|
| VNet address space | VnetLocal | Traffic stays within the VNet |
| 0.0.0.0/0 | Internet | All outbound traffic goes to internet |
| 10.0.0.0/8 | None | RFC 1918 ranges NOT in the VNet are dropped |

### User Defined Routes (UDRs)

UDRs let you **override** system routes. Common uses:

- Force outbound internet traffic through an NVA or Azure Firewall
- Route cross-VNet traffic through a hub appliance
- Create a "black hole" route to intentionally drop traffic

### Next-Hop Types

| Type | Meaning |
|------|---------|
| `Internet` | Route to the internet |
| `VirtualAppliance` | Send to a specific IP (NVA or Azure Firewall) |
| `VnetLocal` | Keep within the VNet |
| `VirtualNetworkGateway` | Send to VPN/ExpressRoute gateway |
| `None` | Drop the traffic (blackhole) |

---

## Prerequisites

- Module 01 completed (hub VNet deployed)

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

Click the badge at the top of this page.

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

| Resource | Subnet | Purpose |
|----------|--------|---------|
| `rt-web` | `snet-web` | Route internet traffic to hub appliance (10.0.4.4) |
| `rt-app` | `snet-app` | Route internet traffic to hub appliance |
| `rt-data` | `snet-data` | Blackhole route — no direct outbound internet |

> **Note:** `10.0.4.4` is a placeholder for the Azure Firewall deployed in Module 05.

---

## Explore

```powershell
az network route-table route list \
  --resource-group rg-azure-networking-labs \
  --route-table-name rt-web --output table
```

**Think about it:** The data tier has a `None` next-hop for `0.0.0.0/0`. What happens to a data-tier VM trying to reach the internet? Is this intentional from a security perspective?

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

Choose your path:
- **Module 05: Azure Firewall** — deploy an actual firewall at the hub appliance IP
- **Module 06: Fault Lab (NSG)** — diagnose and fix a broken NSG configuration
