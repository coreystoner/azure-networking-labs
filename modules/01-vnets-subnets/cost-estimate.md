# Cost Estimate: Module 01 — VNets & Subnets

## Summary

**Estimated cost: $0.00/hr** — This module deploys only free resources.

## Resource Breakdown

| Resource | SKU/Tier | Cost |
|----------|----------|------|
| Virtual Network (`vnet-hub`) | N/A | **Free** |
| Subnet `snet-web` (10.0.1.0/24) | N/A | **Free** |
| Subnet `snet-app` (10.0.2.0/24) | N/A | **Free** |
| Subnet `snet-data` (10.0.3.0/24) | N/A | **Free** |

## Why Is This Free?

Azure Virtual Networks and subnets themselves have no cost. You pay for the resources **within** the VNet (VMs, load balancers, etc.) and for certain network services (VNet Peering egress, VPN Gateway, etc.). Simply creating a VNet and subnets incurs zero charges.

## When Costs Start

- **Module 05 (Azure Firewall):** ~$1.50/hr for the firewall instance
- **Modules 06–07 (Fault Labs):** ~$0.10/hr for small VMs (B1s)
- **VNet Peering (Module 03):** Peering itself is free; cross-region traffic would cost ~$0.01/GB, but this lab keeps both VNets in the same region

## Tips for Minimising Costs

- Modules 01–04 can be left deployed indefinitely at **$0 cost**
- Clean up Module 05 immediately after completing it (Azure Firewall charges by the hour, even when idle)
- Use `cleanup.ps1` or `az group delete` to remove all resources when you're done

## References

- [Azure Virtual Network pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
