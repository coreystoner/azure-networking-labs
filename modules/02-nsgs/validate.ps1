#Requires -Version 5.1
<#
.SYNOPSIS
    Validates Module 02: Network Security Groups completion.
.PARAMETER ResourceGroupName
    Default: rg-azure-networking-labs
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs'
)

$ErrorActionPreference = 'Continue'
$allPassed = $true

function Write-Check {
    param([string]$Description, [bool]$Passed)
    if ($Passed) {
        Write-Host "  [PASS] $Description" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $Description" -ForegroundColor Red
        $script:allPassed = $false
    }
}

Write-Host ''
Write-Host '=================================================' -ForegroundColor Cyan
Write-Host '  Azure Networking Labs -- Module 02 Validator  ' -ForegroundColor Cyan
Write-Host '  Network Security Groups                       ' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan
Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host '[ERROR] Azure CLI not found. See SETUP.md for install instructions.' -ForegroundColor Red; exit 1
}

# Check 1: NSGs exist
Write-Host '[1/3] Checking NSGs exist...' -ForegroundColor White
foreach ($nsgName in @('nsg-web', 'nsg-app', 'nsg-data')) {
    $nsg = az network nsg show --resource-group $ResourceGroupName --name $nsgName 2>$null | ConvertFrom-Json
    Write-Check "NSG '$nsgName' exists" ($null -ne $nsg)
}

# Check 2: NSG associations
Write-Host ''
Write-Host '[2/3] Checking NSG-to-subnet associations...' -ForegroundColor White
$vnet = az network vnet show --resource-group $ResourceGroupName --name 'vnet-hub' 2>$null | ConvertFrom-Json

if ($null -ne $vnet) {
    foreach ($subnetName in @('snet-web', 'snet-app', 'snet-data')) {
        $subnet = $vnet.subnets | Where-Object { $_.name -eq $subnetName }
        $hasNsg = ($null -ne $subnet) -and ($null -ne $subnet.networkSecurityGroup)
        Write-Check "'$subnetName' has an NSG associated" $hasNsg
    }
} else {
    Write-Host '  [SKIP] vnet-hub not found. Deploy Module 01 first.' -ForegroundColor Yellow
    $allPassed = $false
}

# Check 3: Key rules
Write-Host ''
Write-Host '[3/3] Checking key security rules...' -ForegroundColor White

$nsgWeb = az network nsg show --resource-group $ResourceGroupName --name 'nsg-web' 2>$null | ConvertFrom-Json
if ($null -ne $nsgWeb) {
    $httpRule  = $nsgWeb.securityRules | Where-Object { $_.properties.destinationPortRange -eq '80'  -and $_.properties.access -eq 'Allow' }
    $httpsRule = $nsgWeb.securityRules | Where-Object { $_.properties.destinationPortRange -eq '443' -and $_.properties.access -eq 'Allow' }
    Write-Check 'nsg-web allows HTTP (port 80) inbound'   ($null -ne $httpRule)
    Write-Check 'nsg-web allows HTTPS (port 443) inbound' ($null -ne $httpsRule)
    Write-Check 'nsg-web has session key tag' (-not [string]::IsNullOrEmpty($nsgWeb.tags.sessionKey))
}

$nsgApp = az network nsg show --resource-group $ResourceGroupName --name 'nsg-app' 2>$null | ConvertFrom-Json
if ($null -ne $nsgApp) {
    $webTierRule = $nsgApp.securityRules | Where-Object {
        $_.properties.sourceAddressPrefix -eq '10.0.1.0/24' -and $_.properties.access -eq 'Allow'
    }
    Write-Check 'nsg-app allows inbound from 10.0.1.0/24 (web tier)' ($null -ne $webTierRule)
}

# Result
Write-Host ''
Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    $sessionKey = $nsgWeb.tags.sessionKey
    if ([string]::IsNullOrEmpty($sessionKey)) {
        Write-Host '[ERROR] Session key tag not found. Re-deploy the module.' -ForegroundColor Red; exit 1
    }
    $unlockCode = "ANL-MOD02-$sessionKey-COMPLETE"
    $padding = '-' * ($unlockCode.Length + 4)
    $border  = "  +$padding+"
    Write-Host '  ALL CHECKS PASSED!' -ForegroundColor Green
    Write-Host ''
    Write-Host '  Your Module 02 unlock code:' -ForegroundColor White
    Write-Host ''
    Write-Host $border -ForegroundColor Yellow
    Write-Host "  |  $unlockCode  |" -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  Enter this code in the portal to unlock Module 03.' -ForegroundColor White
} else {
    Write-Host '  VALIDATION FAILED -- check output above.' -ForegroundColor Red
    Write-Host '  Re-run the deployment and try again.' -ForegroundColor Yellow
}
Write-Host '=================================================' -ForegroundColor Cyan
Write-Host ''
