# Module 05: Azure Firewall

## Learning Objectives

- Deploy Azure Firewall in the hub VNet
- Create a Firewall Policy with network rules, application rules, and DNAT rules
- Understand the difference between Classic rules and Firewall Policy
- Route traffic through the firewall using UDRs (from Module 04)
- Explain the role of `AzureFirewallSubnet` and its size requirement

---

## ⚠️ Cost Warning

**Azure Firewall costs approximately $1.25–$1.50/hr** depending on SKU. This is the most expensive module in the series. **Run `cleanup.ps1` as soon as you complete validation** to avoid unnecessary charges.

See [cost-estimate.md](./cost-estimate.md) for the full breakdown.

---

## Background: Key Concepts

### Azure Firewall Architecture

Azure Firewall is a cloud-native, stateful firewall-as-a-service. It:
- Deploys into a dedicated `AzureFirewallSubnet` (/26 minimum) in your hub VNet
- Has a public IP for internet-facing traffic
- Processes all traffic that UDRs direct to it
- Supports FQDN-based application rules (not just IP/port)

### Rule Types

| Rule Type | Layer | Example Use Case |
|-----------|-------|------------------|
| **Network rules** | L3/L4 (IP, port, protocol) | Allow SQL (1433) from app tier to data tier |
| **Application rules** | L7 (FQDN, protocol) | Allow `*.microsoft.com` HTTPS outbound |
| **DNAT rules** | Inbound NAT | Expose a VM RDP behind a public IP |

Rules are evaluated: DNAT → Network → Application. First match wins.

### Firewall Policy vs Classic Rules

- **Firewall Policy** (recommended): A separate resource that can be shared across multiple firewalls; supports rule hierarchies
- **Classic rules**: Directly on the firewall resource; simpler but less flexible

This module uses **Firewall Policy**.

---

## Prerequisites

- Module 01 completed (hub VNet with `10.0.0.0/16` address space)
- **Ensure you have budget/credits available** — this module costs ~$1.50/hr

---

## Deploy the Module

```powershell
cd modules/05-azure-firewall

az deployment group create \
  --resource-group rg-azure-networking-labs \
  --template-file deploy.bicep
```

> The deployment takes approximately **5–10 minutes** (Azure Firewall provisions slowly).

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
# View the firewall private IP (should be 10.0.4.4)
az network firewall show \
  --resource-group rg-azure-networking-labs \
  --name afw-hub \
  --query 'ipConfigurations[0].privateIPAddress'

# List application rules in the policy
az network firewall policy rule-collection-group list \
  --resource-group rg-azure-networking-labs \
  --policy-name afwp-hub
```

**Think about it:** The UDRs from Module 04 point to `10.0.4.4`. With the firewall now deployed, what would happen to a VM in `snet-web` trying to reach `www.microsoft.com`? Which firewall rule would it match?

---

## ⚠️ Clean Up Immediately

After validating, delete the firewall:

```powershell
.\cleanup.ps1 -ModuleOnly
```

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 06: Fault Lab — NSG** — A misconfigured NSG is blocking traffic. Can you find and fix it?
