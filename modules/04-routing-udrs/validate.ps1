#Requires -Version 5.1
<#
.SYNOPSIS  Validates Module 04: Routing & UDRs.
.PARAMETER ResourceGroupName  Default: rg-azure-networking-labs
#>
param([string]$ResourceGroupName = 'rg-azure-networking-labs')

$ErrorActionPreference = 'Continue'
$allPassed = $true

function Write-Check {
    param([string]$Description, [bool]$Passed)
    if ($Passed) { Write-Host "  [PASS] $Description" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $Description" -ForegroundColor Red; $script:allPassed = $false }
}

Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
Write-Host '  Module 04: Routing & UDRs Validator' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Host '[ERROR] az not found. See SETUP.md.' -ForegroundColor Red; exit 1 }

# Check 1: Route tables exist
Write-Host '[1/3] Checking route tables exist...' -ForegroundColor White
foreach ($rt in @('rt-web', 'rt-app', 'rt-data')) {
    $routeTable = az network route-table show --resource-group $ResourceGroupName --name $rt 2>$null | ConvertFrom-Json
    Write-Check "Route table '$rt' exists" ($null -ne $routeTable)
}

# Check 2: Subnet associations
Write-Host '' ; Write-Host '[2/3] Checking subnet associations...' -ForegroundColor White
$vnet = az network vnet show --resource-group $ResourceGroupName --name 'vnet-hub' 2>$null | ConvertFrom-Json
if ($vnet) {
    foreach ($s in @('snet-web', 'snet-app', 'snet-data')) {
        $subnet = $vnet.subnets | Where-Object { $_.name -eq $s }
        Write-Check "'$s' has a route table" ($null -ne $subnet -and $null -ne $subnet.routeTable)
    }
}

# Check 3: Data tier blackhole
Write-Host '' ; Write-Host '[3/3] Checking data tier blackhole route...' -ForegroundColor White
$rtData = az network route-table show --resource-group $ResourceGroupName --name 'rt-data' 2>$null | ConvertFrom-Json
if ($rtData) {
    $blackhole = $rtData.routes | Where-Object {
        $_.addressPrefix -eq '0.0.0.0/0' -and $_.nextHopType -eq 'None'
    }
    Write-Check 'rt-data has a blackhole route (0.0.0.0/0 -> None)' ($null -ne $blackhole)
}

# Read session key from rt-web
$rtWeb = az network route-table show --resource-group $ResourceGroupName --name 'rt-web' 2>$null | ConvertFrom-Json

# Result
Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    $sessionKey = $rtWeb.tags.sessionKey
    if ([string]::IsNullOrEmpty($sessionKey)) {
        Write-Host '[ERROR] Session key tag not found. Re-deploy the module.' -ForegroundColor Red; exit 1
    }
    $unlockCode = "ANL-MOD04-$sessionKey-COMPLETE"
    $padding = '-' * ($unlockCode.Length + 4)
    $border  = "  +$padding+"
    Write-Host '  ALL CHECKS PASSED!' -ForegroundColor Green ; Write-Host ''
    Write-Host '  Your Module 04 unlock code:' -ForegroundColor White ; Write-Host ''
    Write-Host $border -ForegroundColor Yellow
    Write-Host "  |  $unlockCode  |" -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Yellow
    Write-Host '' ; Write-Host '  Enter this in the portal. Modules 05 and 06 will unlock.' -ForegroundColor White
} else {
    Write-Host '  VALIDATION FAILED -- check output above.' -ForegroundColor Red
}
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
