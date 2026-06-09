# Module 04: Routing & User Defined Routes (UDRs)

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

When you create a VNet, Azure automatically creates **system routes** for traffic within the address space:

| Destination | Next Hop | Notes |
|-------------|----------|-------|
| VNet address space | VnetLocal | Traffic stays within the VNet |
| 0.0.0.0/0 | Internet | All outbound traffic goes to internet |
| 10.0.0.0/8 | None | RFC 1918 ranges NOT in the VNet are dropped |
| 172.16.0.0/12 | None | Same |
| 192.168.0.0/16 | None | Same |

### User Defined Routes (UDRs)

UDRs let you **override** the system routes. Common uses:

- Force all outbound internet traffic through an NVA or Azure Firewall
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

### BGP Route Propagation

If you have a VPN or ExpressRoute gateway, it advertises on-premises routes via BGP. You can **disable** BGP propagation on a route table so gateway routes don't override your UDRs.

---

## Prerequisites

- Module 01 completed (hub VNet deployed)

---

## Deploy the Module

```powershell
cd modules/04-routing-udrs

az deployment group create \
  --resource-group rg-azure-networking-labs \
  --template-file deploy.bicep
```

---

## What Was Deployed

| Resource | Subnet | Purpose |
|----------|--------|---------|
| `rt-web` | `snet-web` | UDR: direct all non-VNet traffic to a hub appliance IP |
| `rt-app` | `snet-app` | UDR: direct all non-VNet traffic to hub appliance |
| `rt-data` | `snet-data` | Blackhole route: data tier has no direct outbound internet |

> **Note:** The "hub appliance IP" (`10.0.4.4`) is a placeholder representing where an Azure Firewall or NVA would sit. Module 05 deploys an actual firewall there.

---

## Explore

```powershell
# View routes on rt-web
az network route-table route list \
  --resource-group rg-azure-networking-labs \
  --route-table-name rt-web \
  --output table

# Check effective routes for a subnet (shows system + UDR combined)
# If a VM NIC is available:
# az network nic show-effective-route-table --resource-group rg-azure-networking-labs --name <nic-name> --output table
```

**Think about it:** The data tier has a `None` next-hop route for `0.0.0.0/0`. What happens to any traffic from a data-tier VM trying to reach the internet? Is this intentional from a security perspective?

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
