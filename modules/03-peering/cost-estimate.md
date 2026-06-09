# Cost Estimate: Module 03 — VNet Peering

## Summary

**Estimated cost: $0.00/hr** (in lab conditions)

## Resource Breakdown

| Resource | Cost |
|----------|------|
| VNet `vnet-spoke1` | Free |
| VNet peering (2x) | Free |
| Intra-region peering data transfer | $0.01/GB* |

*In this lab no actual data is transferred between VNets (no VMs are running), so the data transfer cost is $0.00.

## Notes

VNet peering itself has no hourly charge. You pay only for data that **flows across** the peering. In this module, we are only creating the peering and inspecting configuration — no VM-to-VM traffic is generated.

If you later deploy VMs and transfer data between the hub and spoke:
- **Same region:** $0.01/GB in each direction
- **Cross-region (global peering):** $0.025–$0.05/GB depending on regions

## References

- [VNet peering pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)
