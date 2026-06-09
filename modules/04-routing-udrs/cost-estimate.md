# Cost Estimate: Module 04 — Routing & UDRs

## Summary

**Estimated cost: $0.00/hr** — Route tables are free in Azure.

## Resource Breakdown

| Resource | Cost |
|----------|------|
| Route table `rt-web` | Free |
| Route table `rt-app` | Free |
| Route table `rt-data` | Free |
| Routes (unlimited per table) | Free |

## Notes

Route tables and UDRs have no hourly charge. The `VirtualAppliance` routes point to `10.0.4.4` (the future Azure Firewall IP), but since no firewall is deployed in this module, traffic matching those routes will be dropped. This is expected — no VMs are deployed in this lab.

Module 05 (Azure Firewall) will be significantly more expensive (~$1.50/hr) and should be cleaned up promptly after completion.

## References

- [Azure Route table pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/) (free)
