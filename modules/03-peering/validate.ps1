#Requires -Version 5.1
<#
.SYNOPSIS  Validates Module 03: VNet Peering.
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
Write-Host '  Module 03: VNet Peering Validator' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Host '[ERROR] az not found. See SETUP.md.' -ForegroundColor Red; exit 1 }

# Check 1: Spoke VNet
Write-Host '[1/3] Checking spoke VNet...' -ForegroundColor White
$spoke = az network vnet show --resource-group $ResourceGroupName --name 'vnet-spoke1' 2>$null | ConvertFrom-Json
Write-Check "VNet 'vnet-spoke1' exists" ($null -ne $spoke)
if ($spoke) {
    Write-Check 'Spoke address space is 10.1.0.0/16' ($spoke.addressSpace.addressPrefixes -contains '10.1.0.0/16')
    $subnetNames = $spoke.subnets | ForEach-Object { $_.name }
    Write-Check "Subnet 'snet-workloads' exists in spoke" ($subnetNames -contains 'snet-workloads')
    Write-Check 'Spoke has session key tag' (-not [string]::IsNullOrEmpty($spoke.tags.sessionKey))
}

# Check 2: Hub -> Spoke peering
Write-Host '' ; Write-Host '[2/3] Checking hub -> spoke peering...' -ForegroundColor White
$peerH2S = az network vnet peering show --resource-group $ResourceGroupName --vnet-name 'vnet-hub' --name 'peer-hub-to-spoke1' 2>$null | ConvertFrom-Json
Write-Check "Peering 'peer-hub-to-spoke1' exists" ($null -ne $peerH2S)
if ($peerH2S) { Write-Check 'Hub->Spoke peering state is Connected' ($peerH2S.peeringState -eq 'Connected') }

# Check 3: Spoke -> Hub peering
Write-Host '' ; Write-Host '[3/3] Checking spoke -> hub peering...' -ForegroundColor White
$peerS2H = az network vnet peering show --resource-group $ResourceGroupName --vnet-name 'vnet-spoke1' --name 'peer-spoke1-to-hub' 2>$null | ConvertFrom-Json
Write-Check "Peering 'peer-spoke1-to-hub' exists" ($null -ne $peerS2H)
if ($peerS2H) { Write-Check 'Spoke->Hub peering state is Connected' ($peerS2H.peeringState -eq 'Connected') }

# Result
Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    $sessionKey = $spoke.tags.sessionKey
    if ([string]::IsNullOrEmpty($sessionKey)) {
        Write-Host '[ERROR] Session key tag not found. Re-deploy the module.' -ForegroundColor Red; exit 1
    }
    $unlockCode = "ANL-MOD03-$sessionKey-COMPLETE"
    $padding = '-' * ($unlockCode.Length + 4)
    $border  = "  +$padding+"
    Write-Host '  ALL CHECKS PASSED!' -ForegroundColor Green ; Write-Host ''
    Write-Host '  Your Module 03 unlock code:' -ForegroundColor White ; Write-Host ''
    Write-Host $border -ForegroundColor Yellow
    Write-Host "  |  $unlockCode  |" -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Yellow
    Write-Host '' ; Write-Host '  Enter this code in the portal to unlock Module 04.' -ForegroundColor White
} else {
    Write-Host '  VALIDATION FAILED -- check output above.' -ForegroundColor Red
}
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
