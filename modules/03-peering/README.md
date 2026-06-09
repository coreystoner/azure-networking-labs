# Module 03: VNet Peering

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F03-peering%2Fdeploy.bicep)

## Learning Objectives

- Describe hub-and-spoke VNet topology and its benefits
- Create a spoke VNet and establish bidirectional peering
- Explain why peering requires two peering resources (one per direction)
- Understand peering states (Initiated → Connected)
- Identify traffic flow limitations of basic peering (no transitivity)

---

## Background: Key Concepts

### VNet Peering

VNet peering connects two Azure VNets so resources in each can communicate using private IP addresses — as if they were on the same network. Traffic flows over the Microsoft backbone (not the public internet) and has low latency.

### Why Two Peering Resources?

Peering is **not automatic in both directions**. You must create:
1. A peering from Hub → Spoke (on the hub VNet)
2. A peering from Spoke → Hub (on the spoke VNet)

Both must be in **Connected** state before traffic flows.

### Hub-and-Spoke Topology

```
         [Internet]
              |
         [vnet-hub]        ← shared services, firewall, gateway
        /     |     \
[spoke1] [spoke2] [spoke3]  ← workload VNets
```

### Peering Limitations

- Peering is **non-transitive** by default
- Address spaces of peered VNets **cannot overlap**
- Global peering (cross-region) incurs small data transfer costs

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

| Resource | Details |
|----------|---------|
| `vnet-spoke1` | New spoke VNet, address space `10.1.0.0/16` |
| `snet-workloads` | Subnet in spoke1, `10.1.1.0/24` |
| `peer-hub-to-spoke1` | Peering from hub → spoke1 |
| `peer-spoke1-to-hub` | Peering from spoke1 → hub |

---

## Explore

```powershell
# Check peering status — both should show 'Connected'
az network vnet peering list \
  --resource-group rg-azure-networking-labs \
  --vnet-name vnet-hub --output table

az network vnet peering list \
  --resource-group rg-azure-networking-labs \
  --vnet-name vnet-spoke1 --output table
```

**Think about it:** If you add `vnet-spoke2`, what's needed for spoke1 to reach spoke2 via the hub? (Hint: `allowForwardedTraffic`.)

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 04: Routing & UDRs** — Take control of how traffic flows through your VNets with custom route tables.
