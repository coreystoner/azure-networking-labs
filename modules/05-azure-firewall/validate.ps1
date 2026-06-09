#Requires -Version 5.1
<#
.SYNOPSIS  Validates Module 05: Azure Firewall.
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
Write-Host '  Module 05: Azure Firewall Validator' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
Write-Host '  REMINDER: Run cleanup.ps1 -ModuleOnly after validating!' -ForegroundColor Yellow ; Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Host '[ERROR] az not found. See SETUP.md.' -ForegroundColor Red; exit 1 }

Write-Host '[1/4] Checking AzureFirewallSubnet...' -ForegroundColor White
$subnet = az network vnet subnet show --resource-group $ResourceGroupName --vnet-name 'vnet-hub' --name 'AzureFirewallSubnet' 2>$null | ConvertFrom-Json
Write-Check "'AzureFirewallSubnet' exists in vnet-hub" ($null -ne $subnet)
if ($subnet) { Write-Check 'Subnet prefix is 10.0.4.0/26 (minimum /26 required)' ($subnet.addressPrefix -eq '10.0.4.0/26') }

Write-Host '' ; Write-Host '[2/4] Checking Firewall Policy...' -ForegroundColor White
$policy = az network firewall policy show --resource-group $ResourceGroupName --name 'afwp-hub' 2>$null | ConvertFrom-Json
Write-Check "Firewall Policy 'afwp-hub' exists" ($null -ne $policy)

Write-Host '' ; Write-Host '[3/4] Checking Azure Firewall...' -ForegroundColor White
$fw = az network firewall show --resource-group $ResourceGroupName --name 'afw-hub' 2>$null | ConvertFrom-Json
Write-Check "Azure Firewall 'afw-hub' exists" ($null -ne $fw)
if ($fw) {
    Write-Check "Firewall provisioning state is 'Succeeded'" ($fw.provisioningState -eq 'Succeeded')
    Write-Check 'Firewall private IP is 10.0.4.4' ($fw.ipConfigurations[0].privateIPAddress -eq '10.0.4.4')
    Write-Check 'Firewall has session key tag' (-not [string]::IsNullOrEmpty($fw.tags.sessionKey))
}

Write-Host '' ; Write-Host '[4/4] Checking Public IP...' -ForegroundColor White
$pip = az network public-ip show --resource-group $ResourceGroupName --name 'pip-afw-hub' 2>$null | ConvertFrom-Json
Write-Check "Public IP 'pip-afw-hub' exists" ($null -ne $pip)

# Result
Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    $sessionKey = $fw.tags.sessionKey
    if ([string]::IsNullOrEmpty($sessionKey)) {
        Write-Host '[ERROR] Session key tag not found. Re-deploy the module.' -ForegroundColor Red; exit 1
    }
    $unlockCode = "ANL-MOD05-$sessionKey-COMPLETE"
    $padding = '-' * ($unlockCode.Length + 4)
    $border  = "  +$padding+"
    Write-Host '  ALL CHECKS PASSED!' -ForegroundColor Green ; Write-Host ''
    Write-Host '  Your Module 05 unlock code:' -ForegroundColor White ; Write-Host ''
    Write-Host $border -ForegroundColor Yellow
    Write-Host "  |  $unlockCode  |" -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  *** IMPORTANT: Delete the firewall now to stop charges! ***' -ForegroundColor Red
    Write-Host '  Run: .\cleanup.ps1 -ModuleOnly' -ForegroundColor Yellow
} else {
    Write-Host '  VALIDATION FAILED' -ForegroundColor Red
}
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
