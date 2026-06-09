# Module 03: VNet Peering

## Learning Objectives

- Describe hub-and-spoke VNet topology and its benefits
- Create a spoke VNet and establish bidirectional peering
- Explain why peering requires two peering resources (one per direction)
- Understand peering states (Initiated → Connected)
- Identify traffic flow limitations of basic peering (no transitivity)

---

## Background: Key Concepts

### VNet Peering

VNet peering connects two Azure VNets using private IP addresses over the Microsoft backbone. Traffic never traverses the public internet.

### Why Two Peering Resources?

Peering is **not automatic in both directions**. You must create one peering on each VNet. Both must reach **Connected** state before traffic flows.

### Hub-and-Spoke Topology

```
         [Internet]
              |
         [vnet-hub]        ← shared services, firewall, gateway
        /     |     \
[spoke1] [spoke2] [spoke3]  ← workload VNets
```

---

## Prerequisites

- Module 01 completed (hub VNet deployed)
- Azure CLI installed and logged in — [CLI Setup Guide →](../../SETUP.md)

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F03-peering%2Fdeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/></a>

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

| Resource | Details |
|----------|---------|
| `vnet-spoke1` | New spoke VNet, address space `10.1.0.0/16` |
| `snet-workloads` | Subnet in spoke1, `10.1.1.0/24` |
| `peer-hub-to-spoke1` | Peering from hub → spoke1 |
| `peer-spoke1-to-hub` | Peering from spoke1 → hub |

---

## Explore

```powershell
az network vnet peering list `
  --resource-group rg-azure-networking-labs `
  --vnet-name vnet-hub --output table
```

**Think about it:** If you add `vnet-spoke2`, what's needed for spoke1 to reach spoke2 via the hub? (Hint: `allowForwardedTraffic`.)

---

## Validate Your Work

> **First time?** [CLI Setup Guide →](../../SETUP.md)

1. Navigate to this module folder:

   ```powershell
   cd path\to\azure-networking-labs\modules\03-peering
   ```

2. Run the validation script:

   ```powershell
   .\validate.ps1
   ```

3. Copy the unlock code from the output and enter it in the **learning portal**.

---

## Next Up

**Module 04: Routing & UDRs** — Take control of how traffic flows through your VNets with custom route tables.
