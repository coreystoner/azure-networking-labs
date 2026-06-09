# CLI Setup Guide

This guide walks you through installing and configuring the Azure CLI so you can run the validation scripts in each module.

> **Estimated time:** 5–10 minutes (one-time setup)

---

## Step 1 — Install Azure CLI

### Windows

1. Download the installer: **https://aka.ms/installazurecliwindows**
2. Run the `.msi` file and follow the prompts
3. Open a **new** PowerShell window after installation

### macOS

```bash
brew update && brew install azure-cli
```

### Linux (Ubuntu/Debian)

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

For other distros: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux

### Verify Installation

After installing, confirm it works:

```powershell
az --version
```

You should see output like `azure-cli 2.x.x`. If you get "command not found", close and reopen your terminal.

---

## Step 2 — Log In to Azure

```powershell
az login
```

This opens a browser window. Sign in with your Azure account. When complete, your terminal will show your subscriptions.

**If you have multiple subscriptions**, set the one you want to use:

```powershell
# List your subscriptions
az account list --output table

# Set the active subscription by ID
az account set --subscription "your-subscription-id"
```

---

## Step 3 — Fix PowerShell Execution Policy (Windows only)

Windows blocks unsigned scripts by default. Run this **once** to allow local scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Type `Y` and press Enter when prompted.

---

## Step 4 — Clone the Repo

If you haven't already:

```powershell
git clone https://github.com/coreystoner/azure-networking-labs.git
cd azure-networking-labs
```

If you don't have Git: https://git-scm.com/downloads

---

## Step 5 — Run Your First Validation

Navigate to the module folder and run the script:

```powershell
cd modules\01-vnets-subnets
.\validate.ps1
```

On success you'll see a box containing your **unique unlock code** for this deployment:

```
  +=================================+
  |  ANL-MOD01-A1B2C3D4-COMPLETE  |
  +=================================+
```

> **Note:** The 8-character session ID (`A1B2C3D4` above) is unique to your deployment. It is generated at deploy time and cannot be predicted — you must run the deployment and validate.ps1 to get your code.

Copy the code and enter it in the learning portal to unlock the next module.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `az: command not found` | Close and reopen your terminal after installing Azure CLI |
| `Not logged in to Azure` | Run `az login` |
| `cannot be loaded because running scripts is disabled` | Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `Resource group not found` | Deploy the module first (Option A or B in the module README) |
| `VALIDATION FAILED` | Read the `[FAIL]` lines — they tell you exactly what's missing |
| `No subscriptions found` | Make sure you signed into the correct Microsoft account |
| `Session key tag not found` | Re-deploy the module — old deployments lack the tag |

---

## Not Using the CLI?

If you deployed via **Option A (Deploy to Azure portal button)**, you can still validate via CLI — the script just reads what's already deployed. You only need to deploy once.
