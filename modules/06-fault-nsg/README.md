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
  --nsg-name nsg-web-fault \
  --output table
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

There is a `Block-All-Inbound` rule at priority **90** — it is evaluated before the `Allow-HTTP-Inbound` rule at priority 100, blocking all traffic.

Fix: Change the `Block-All-Inbound` rule priority to **4000** (evaluated last, as a catch-all deny):

```powershell
az network nsg rule update \
  --resource-group rg-azure-networking-labs \
  --nsg-name nsg-web-fault \
  --name Block-All-Inbound \
  --priority 4000
```

</details>

---

## Prerequisites

- Module 01 completed (hub VNet deployed)

---

## Deploy the Broken Environment

```powershell
cd modules/06-fault-nsg

az deployment group create \
  --resource-group rg-azure-networking-labs \
  --template-file deploy.bicep
```

---

## Your Task

1. Identify why HTTP traffic is blocked despite the allow rule
2. Fix the misconfiguration using `az network nsg rule update`
3. Run `validate.ps1` to confirm your fix is correct

---

## Validate

```powershell
.\validate.ps1
```

---

## Next Up

**Module 07: Fault Lab — Routing** — A VM has lost internet connectivity. The route table looks fine… or does it?
