#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Networking Labs — Master setup and deployment script.
.DESCRIPTION
    One-stop script that handles:
      - Azure CLI prerequisite check
      - Azure login (interactive or existing session)
      - Resource group creation
      - Module deployment
      - Optional immediate validation

    Run this from the repo root OR run the Start-Module.ps1 inside any
    module folder (which calls this script automatically).

.PARAMETER Module
    Module number to deploy (01 through 07). Omit to run setup only.
.PARAMETER ResourceGroupName
    Name of the resource group. Default: rg-azure-networking-labs
.PARAMETER Location
    Azure region. Default: eastus
.PARAMETER SkipValidation
    Skip running validate.ps1 after a successful deployment.
.PARAMETER Force
    Skip all confirmation prompts.

.EXAMPLE
    # Interactive guided start
    .\Start-Lab.ps1

.EXAMPLE
    # Deploy module 01 directly
    .\Start-Lab.ps1 -Module 01

.EXAMPLE
    # Deploy module 03 to a custom resource group in westus2
    .\Start-Lab.ps1 -Module 03 -ResourceGroupName my-lab-rg -Location westus2
#>
[CmdletBinding()]
param(
    [ValidateSet('01','02','03','04','05','06','07','')]
    [string]$Module = '',

    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [string]$Location          = 'eastus',
    [switch]$SkipValidation,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Header {
    param([string]$Text)
    $line = '=' * 55
    Write-Host ''
    Write-Host $line -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
    Write-Host ''
}

function Write-Step {
    param([string]$Icon, [string]$Text)
    Write-Host "  $Icon  $Text" -ForegroundColor White
}

function Write-OK   { param([string]$T) Write-Host "  [OK] $T" -ForegroundColor Green }
function Write-Warn { param([string]$T) Write-Host "  [!!] $T" -ForegroundColor Yellow }
function Write-Fail { param([string]$T) Write-Host "  [X] $T" -ForegroundColor Red }

function Confirm-Step {
    param([string]$Message)
    if ($Force) { return $true }
    $reply = Read-Host "  --> $Message [Y/n]"
    return ($reply -eq '' -or $reply -match '^[Yy]')
}

$ModuleMap = @{
    '01' = @{ Name = 'VNets & Subnets';        Path = 'modules/01-vnets-subnets'    }
    '02' = @{ Name = 'Network Security Groups'; Path = 'modules/02-nsgs'             }
    '03' = @{ Name = 'VNet Peering';            Path = 'modules/03-peering'          }
    '04' = @{ Name = 'Routing & UDRs';          Path = 'modules/04-routing-udrs'     }
    '05' = @{ Name = 'Azure Firewall';          Path = 'modules/05-azure-firewall'   }
    '06' = @{ Name = 'Fault Lab: NSG';          Path = 'modules/06-fault-nsg'        }
    '07' = @{ Name = 'Fault Lab: Routing';      Path = 'modules/07-fault-routing'    }
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
Write-Header 'Azure Networking Labs'
Write-Host '  github.com/coreystoner/azure-networking-labs' -ForegroundColor Gray
Write-Host ''

# ---------------------------------------------------------------------------
# Step 1: Check Azure CLI
# ---------------------------------------------------------------------------
Write-Step 'Step 1/4' 'Checking prerequisites...'

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Fail 'Azure CLI not found.'
    Write-Host ''
    Write-Host '  Install it from: https://aka.ms/installazurecliwindows' -ForegroundColor Yellow
    Write-Host '  Then re-run this script.' -ForegroundColor Yellow
    exit 1
}

$cliVersion = (az version 2>$null | ConvertFrom-Json).'azure-cli'
Write-OK "Azure CLI $cliVersion found."

# ---------------------------------------------------------------------------
# Step 2: Login / subscription
# ---------------------------------------------------------------------------
Write-Host ''
Write-Step 'Step 2/4' 'Checking Azure login...'

$account = az account show 2>$null | ConvertFrom-Json

if (-not $account) {
    Write-Warn 'Not logged in. Launching browser login...'
    Write-Host ''
    az login
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Fail 'Login failed. Please run: az login'
        exit 1
    }
}

Write-OK "Logged in as: $($account.user.name)"
Write-OK "Subscription: $($account.name) ($($account.id))"

# Let user switch subscription if they want
Write-Host ''
if (-not $Force) {
    $switch = Read-Host '  Use this subscription? [Y/n]'
    if ($switch -match '^[Nn]') {
        Write-Host ''
        Write-Host '  Available subscriptions:' -ForegroundColor White
        az account list --output table
        Write-Host ''
        $subId = Read-Host '  Enter subscription name or ID'
        az account set --subscription $subId
        $account = az account show | ConvertFrom-Json
        Write-OK "Switched to: $($account.name)"
    }
}

# ---------------------------------------------------------------------------
# Step 3: Resource Group
# ---------------------------------------------------------------------------
Write-Host ''
Write-Step 'Step 3/4' "Checking resource group '$ResourceGroupName'..."

$rg = az group show --name $ResourceGroupName 2>$null | ConvertFrom-Json

if (-not $rg) {
    Write-Warn "Resource group '$ResourceGroupName' not found."
    if (Confirm-Step "Create it in '$Location'?") {
        Write-Host '  Creating...' -ForegroundColor Gray
        az group create --name $ResourceGroupName --location $Location --output none
        Write-OK "Created '$ResourceGroupName' in $Location."
    } else {
        Write-Fail 'Resource group required. Exiting.'
        exit 1
    }
} else {
    Write-OK "'$ResourceGroupName' exists in $($rg.location)."
}

# ---------------------------------------------------------------------------
# Step 4: Deploy module (if specified)
# ---------------------------------------------------------------------------
if ($Module -eq '') {
    # No module specified — offer a menu
    Write-Host ''
    Write-Host '  Available modules:' -ForegroundColor White
    foreach ($k in ($ModuleMap.Keys | Sort-Object)) {
        Write-Host "    [$k] $($ModuleMap[$k].Name)" -ForegroundColor Gray
    }
    Write-Host ''
    $Module = (Read-Host '  Enter module number (01-07) or Q to quit').Trim()
    if ($Module -match '^[Qq]') { Write-Host '  Exiting.'; exit 0 }
    if (-not $ModuleMap.ContainsKey($Module)) {
        Write-Fail "Unknown module: $Module"
        exit 1
    }
}

$mod     = $ModuleMap[$Module]
$modPath = Join-Path $PSScriptRoot $mod.Path
$bicep   = Join-Path $modPath 'deploy.bicep'

Write-Host ''
Write-Step 'Step 4/4' "Deploying Module $Module: $($mod.Name)..."

if (-not (Test-Path $bicep)) {
    Write-Fail "Bicep file not found: $bicep"
    Write-Host '  Make sure you cloned the full repository.' -ForegroundColor Yellow
    exit 1
}

# Cost warning for module 05
if ($Module -eq '05') {
    Write-Host ''
    Write-Warn 'Azure Firewall costs ~$1.25-1.50/hr!'
    Write-Warn 'Run cleanup.ps1 -ModuleOnly immediately after validating.'
    Write-Host ''
    if (-not (Confirm-Step 'Continue with Module 05 deployment?')) {
        Write-Host '  Cancelled.'; exit 0
    }
}

Write-Host ''
Write-Host '  Running deployment...' -ForegroundColor Gray
Write-Host '  (this may take 1-10 min depending on the module)' -ForegroundColor Gray
Write-Host ''

$deployStart = Get-Date

$deployResult = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $bicep `
    --output json 2>&1

$exitCode = $LASTEXITCODE
$elapsed  = [int]((Get-Date) - $deployStart).TotalSeconds

if ($exitCode -ne 0) {
    Write-Host ''
    Write-Fail "Deployment failed after ${elapsed}s."
    Write-Host ''
    Write-Host '  Error output:' -ForegroundColor Yellow
    $deployResult | Where-Object { $_ -match 'ERROR|error|Error' } | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Red
    }
    Write-Host ''
    Write-Host '  Full log: Run the command below for details:' -ForegroundColor Yellow
    Write-Host "  az deployment group show --resource-group $ResourceGroupName --name deploy" -ForegroundColor Gray
    exit 1
}

Write-OK "Deployment succeeded in ${elapsed}s."

# Show outputs
$result = $deployResult | ConvertFrom-Json -ErrorAction SilentlyContinue
if ($result -and $result.properties.outputs) {
    Write-Host ''
    Write-Host '  Deployment outputs:' -ForegroundColor White
    $result.properties.outputs.PSObject.Properties | ForEach-Object {
        Write-Host "    $($_.Name) = $($_.Value.value)" -ForegroundColor Gray
    }
}

# ---------------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------------
$validateScript = Join-Path $modPath 'validate.ps1'

if (-not $SkipValidation -and (Test-Path $validateScript)) {
    Write-Host ''
    if (Confirm-Step 'Run validation now?') {
        Write-Host ''
        & $validateScript -ResourceGroupName $ResourceGroupName
    } else {
        Write-Host ''
        Write-Host '  Run validation later:' -ForegroundColor White
        Write-Host "  cd $($mod.Path)" -ForegroundColor Gray
        Write-Host '  .\validate.ps1' -ForegroundColor Gray
    }
}

Write-Host ''
