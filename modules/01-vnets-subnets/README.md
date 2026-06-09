# Module 01: VNets & Subnets

## Learning Objectives

By the end of this module you will be able to:

- Explain what an Azure Virtual Network (VNet) is and why address space planning matters
- Create a VNet with a custom address space using Bicep
- Segment a VNet into subnets for different workload tiers
- Describe how Azure reserves IP addresses within each subnet
- Follow Azure naming conventions for network resources

---

## Background: Key Concepts

### Virtual Networks (VNets)

An Azure VNet is a logically isolated network in the cloud. It's the fundamental building block of Azure networking — similar to a traditional on-premises LAN, but software-defined. Resources within a VNet can communicate with each other by default, but are isolated from other VNets and the internet unless you explicitly configure connectivity.

### Address Spaces and CIDR Notation

Every VNet has an **address space** — a range of private IP addresses expressed in CIDR notation (e.g., `10.0.0.0/16`).

| CIDR | Addresses | Usable* |
|------|-----------|--------|
| /16 | 65,536 | 65,531 |
| /24 | 256 | 251 |
| /26 | 64 | 59 |
| /28 | 16 | 11 |

*Azure reserves 5 addresses per subnet: network address, first usable (default gateway), next two (DNS), and broadcast.

### Subnets

Subnets divide a VNet's address space into smaller segments. Best practice is to segment by workload tier:

- **Web tier** (`snet-web`) — load balancers, public-facing resources
- **App tier** (`snet-app`) — business logic, backend services
- **Data tier** (`snet-data`) — databases, caches

This separation makes it easy to apply different NSG rules (Module 02) to each tier.

---

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- A resource group created: `rg-azure-networking-labs`

```powershell
# Log in (if you haven't already)
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Create the shared resource group
az group create --name rg-azure-networking-labs --location eastus
```

---

## Deploy the Module

```powershell
cd modules/01-vnets-subnets

az deployment group create \
  --resource-group rg-azure-networking-labs \
  --template-file deploy.bicep
```

The deployment takes about 30 seconds. When complete, you'll see output showing the VNet name, ID, and subnet IDs.

---

## What Was Deployed

| Resource | Name | Address Space |
|----------|------|---------------|
| Virtual Network | `vnet-hub` | `10.0.0.0/16` |
| Subnet (web) | `snet-web` | `10.0.1.0/24` |
| Subnet (app) | `snet-app` | `10.0.2.0/24` |
| Subnet (data) | `snet-data` | `10.0.3.0/24` |

Notice we're using the `10.0.x.x` private range and leaving plenty of address space:
- `10.0.0.0/24` is intentionally skipped (reserved for future management/gateway subnets)
- `10.0.4.0/24` onward is available for future modules (firewall, etc.)

---

## Explore

Before validating, explore what was deployed:

```powershell
# List all subnets
az network vnet subnet list \
  --resource-group rg-azure-networking-labs \
  --vnet-name vnet-hub \
  --output table

# Check how many usable IPs are in snet-web
az network vnet subnet show \
  --resource-group rg-azure-networking-labs \
  --vnet-name vnet-hub \
  --name snet-web \
  --query '{name:name, prefix:addressPrefix, availableIPs:ipConfigurations}'
```

**Think about it:** If you needed a fourth subnet for a management jumpbox and wanted to keep it small, what CIDR block would you use from the remaining `10.0.0.0/16` space?

---

## Validate

Run the validation script to check your deployment:

```powershell
.\validate.ps1
```

If all checks pass, the script will output your **unlock code**. Copy it and enter it in the learning portal to complete this module.

---

## Cleanup

This module uses no billed resources. You can leave it deployed for Module 02, or clean up:

```powershell
.\cleanup.ps1
```

---

## Next Up

**Module 02: Network Security Groups** — Add traffic control to your subnets with inbound and outbound security rules.
