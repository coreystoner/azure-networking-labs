# Module 06: Fault Lab — NSG

## Scenario

Your team has deployed a web application in a new subnet. The NSG team claims they've added an inbound rule to allow HTTP traffic (port 80) from the internet. However, **no HTTP traffic is getting through**.

Your job: **find the misconfiguration and fix it.**

---

## Hints (try without first!)

<details>
<summary>💡 Hint 1 — Where to look</summary>

Check the NSG attached to `snet-web-fault`. List all the security rules, including priorities.

```powershell
az network nsg rule list \
  --resource-group rg-azure-networking-labs \
  --nsg-name nsg-web-fault --output table
```

Pay close attention to the **priority numbers**.
</details>

<details>
<summary>💡 Hint 2 — What to look for</summary>

NSG rules are evaluated **lowest priority number first**. A rule with priority 90 is evaluated **before** a rule with priority 100.

Is there a Deny rule with a lower priority number than your Allow-HTTP rule?
</details>

<details>
<summary>💡 Hint 3 — The fix</summary>

There is a `Block-All-Inbound` rule at priority **90** — it is evaluated before the `Allow-HTTP-Inbound` rule at priority 100.

```powershell
az network nsg rule update \
  --resource-group rg-azure-networking-labs \
  --nsg-name nsg-web-fault \
  --name Block-All-Inbound \
  --priority 4000
```

</details>

---

## Deploy Options

### 🚀 Option A — One-click (Deploy to Azure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcoreystoner%2Fazure-networking-labs%2Fmain%2Fmodules%2F06-fault-nsg%2Fdeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/></a>

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

1. Identify why HTTP traffic is blocked despite the allow rule
2. Fix the misconfiguration using `az network nsg rule update`
3. Run `validate.ps1` to confirm your fix

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 07: Fault Lab — Routing** — A VM has lost internet connectivity. The route table looks fine… or does it?
