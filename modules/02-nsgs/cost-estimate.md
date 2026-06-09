# Cost Estimate: Module 02 — Network Security Groups

## Summary

**Estimated cost: $0.00/hr** — NSGs are free in Azure.

## Resource Breakdown

| Resource | Cost |
|----------|------|
| NSG `nsg-web` | Free |
| NSG `nsg-app` | Free |
| NSG `nsg-data` | Free |
| NSG rules (up to 1000 per NSG) | Free |

## Notes

Azure NSGs themselves have no cost. You pay only for the resources inside the subnets they protect (VMs, etc.). This module adds only NSGs and rules, so the incremental cost from Module 01 is $0.

## References

- [Azure NSG pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/) (included in VNet pricing — free)
