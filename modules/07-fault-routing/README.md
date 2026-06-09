# Module 07: Fault Lab — Routing

## Scenario

A VM in the `snet-web` subnet has lost internet connectivity. The networking team insists the route table is configured correctly with a route to the internet. You've been asked to investigate.

Your job: **identify why internet traffic isn't flowing and fix it.**

---

## Hints (try without first!)

<details>
<summary>💡 Hint 1 — Where to look</summary>

Check the routes in the route table associated with `snet-web-fault2`:

```powershell
az network route-table route list \
  --resource-group rg-azure-networking-labs \
  --route-table-name rt-web-fault \
  --output table
```

Pay attention to the `nextHopType` column for the `0.0.0.0/0` route.
</details>

<details>
<summary>💡 Hint 2 — What to look for</summary>

A route to `0.0.0.0/0` (all internet traffic) with `nextHopType` of **`None`** is a **blackhole**. Traffic matching this route is silently dropped.

For internet connectivity, the next-hop type should be `Internet` (or `VirtualAppliance` if routing through a firewall).
</details>

<details>
<summary>💡 Hint 3 — The fix</summary>

Update the `route-to-internet` route to use `Internet` as the next hop:

```powershell
az network route-table route update \
  --resource-group rg-azure-networking-labs \
  --route-table-name rt-web-fault \
  --name route-to-internet \
  --next-hop-type Internet
```

</details>

---

## Prerequisites

- Module 01 completed (hub VNet deployed)

---

## Deploy the Broken Environment

```powershell
cd modules/07-fault-routing

az deployment group create \
  --resource-group rg-azure-networking-labs \
  --template-file deploy.bicep
```

---

## Your Task

1. Inspect the route table to identify the misconfiguration
2. Fix the route so internet traffic can flow
3. Run `validate.ps1` to confirm the fix

---

## Validate

```powershell
.\validate.ps1
```

---

## What's Next?

Congratulations — you've completed all seven modules! 🎉

**Suggested next topics:**
- Azure VPN Gateway (site-to-site and point-to-site)
- Azure Private Link & Private Endpoints
- Azure DNS Private Zones
- Azure Virtual WAN
- Network Watcher diagnostics deep dive
