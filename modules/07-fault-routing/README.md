# Module 07: Fault Lab — Routing

## Scenario

A VM in the `snet-web` subnet has lost internet connectivity. The networking team insists the route table is configured correctly. You've been asked to investigate.

Your job: **identify why internet traffic isn't flowing and fix it.**

---

## Hints (try without first!)

<details>
<summary>💡 Hint 1 — Where to look</summary>

```powershell
az network route-table route list `
  --resource-group rg-azure-networking-labs `
  --route-table-name rt-web-fault --output table
```

Pay attention to the `nextHopType` column for the `0.0.0.0/0` route.
</details>

<details>
<summary>💡 Hint 2 — What to look for</summary>

A `nextHopType` of **`None`** is a **blackhole** — traffic is silently dropped. For internet connectivity it should be `Internet`.
</details>

<details>
<summary>💡 Hint 3 — The fix</summary>

```powershell
az network route-table route update `
  --resource-group rg-azure-networking-labs `
  --route-table-name rt-web-fault `
  --name route-to-internet `
  --next-hop-type Internet
```

</details>

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F07-fault-routing%2Fdeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/></a>

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

## Your Task

1. Inspect the route table to identify the misconfiguration
2. Fix the route so internet traffic can flow
3. Run `validate.ps1` to confirm the fix

---

## Validate Your Work

> **First time?** [CLI Setup Guide →](../../SETUP.md)

1. Navigate to this module folder:

   ```powershell
   cd path\to\azure-networking-labs\modules\07-fault-routing
   ```

2. Run the validation script:

   ```powershell
   .\validate.ps1
   ```

3. Copy the unlock code from the output and enter it in the **learning portal**.

---

## Congratulations! 🎉

You've completed all seven modules!

**Suggested next topics:**
- Azure VPN Gateway (site-to-site and point-to-site)
- Azure Private Link & Private Endpoints
- Azure DNS Private Zones
- Azure Virtual WAN
- Network Watcher diagnostics deep dive
