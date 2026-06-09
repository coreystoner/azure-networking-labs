# Cost Estimate: Module 05 — Azure Firewall

## Summary

**Estimated cost: ~$1.25–$1.50/hr** while the firewall is deployed.

> **Action required:** Run `cleanup.ps1 -ModuleOnly` immediately after completing validation.

## Resource Breakdown

| Resource | SKU | Cost |
|----------|-----|------|
| Azure Firewall `afw-hub` | Standard | ~$1.25/hr |
| Public IP `pip-afw-hub` | Standard Static | ~$0.005/hr |
| `AzureFirewallSubnet` subnet | N/A | Free |
| Firewall Policy `afwp-hub` | Standard | ~$0.20/hr (prorated) |
| Data processing | N/A | $0.016/GB (minimal in lab) |

**Total while running:** approximately **$1.25–$1.50/hr**

## Cost Over Time

| Duration | Approx. Cost |
|----------|--------------|
| 1 hour | ~$1.50 |
| 4 hours | ~$6.00 |
| 8 hours (forgotten overnight) | ~$12.00 |
| 24 hours (a full day) | ~$36.00 |

## Minimising Cost

1. Deploy, validate, and clean up in **under 30 minutes** — cost < $0.75
2. Use `cleanup.ps1 -ModuleOnly` to remove only the firewall while keeping other lab resources
3. Set a **budget alert** in Azure Cost Management at $5 to catch any accidental overspend

```powershell
# Set a budget alert (optional but recommended)
az consumption budget create \
  --account-name "YOUR_SUBSCRIPTION_ID" \
  --budget-name "lab-budget" \
  --amount 5 \
  --time-grain monthly \
  --category Cost
```

## References

- [Azure Firewall pricing](https://azure.microsoft.com/en-us/pricing/details/azure-firewall/)
- [Azure Cost Management](https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/)
