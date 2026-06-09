#Requires -Version 5.1
<#
.SYNOPSIS
    Validates Module 01: VNets & Subnets completion.
.DESCRIPTION
    Checks that the expected VNet and subnets exist with the correct configuration,
    then outputs a unique unlock code for the learning portal.
.PARAMETER ResourceGroupName
    The resource group where you deployed the module.
    Default: rg-azure-networking-labs
.EXAMPLE
    .\validate.ps1
.EXAMPLE
    .\validate.ps1 -ResourceGroupName my-custom-rg
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
Write-Host '  Azure Networking Labs -- Module 01 Validator  ' -ForegroundColor Cyan
Write-Host '  VNets & Subnets                               ' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan
Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host '[ERROR] Azure CLI not found.' -ForegroundColor Red
    Write-Host '        Install from: https://aka.ms/installazurecliwindows' -ForegroundColor Yellow
    Write-Host '        Full setup guide: https://github.com/coreystoner/azure-networking-labs/blob/main/SETUP.md' -ForegroundColor Yellow
    exit 1
}

$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host '[ERROR] Not logged in to Azure. Run: az login' -ForegroundColor Red
    exit 1
}
Write-Host "  Subscription: $($account.name)" -ForegroundColor Gray
Write-Host ''

# Check 1: Resource Group
Write-Host '[1/3] Checking resource group...' -ForegroundColor White
$rg = az group show --name $ResourceGroupName 2>$null | ConvertFrom-Json
Write-Check "Resource group '$ResourceGroupName' exists" ($null -ne $rg)

if ($null -eq $rg) {
    Write-Host ''
    Write-Host '[TIP] Create the resource group first:' -ForegroundColor Yellow
    Write-Host "      az group create --name $ResourceGroupName --location eastus" -ForegroundColor Yellow
    exit 1
}

# Check 2: Virtual Network
Write-Host ''
Write-Host '[2/3] Checking virtual network...' -ForegroundColor White
$vnet = az network vnet show `
    --resource-group $ResourceGroupName `
    --name 'vnet-hub' 2>$null | ConvertFrom-Json

Write-Check "VNet 'vnet-hub' exists" ($null -ne $vnet)

if ($null -ne $vnet) {
    Write-Check 'Address space contains 10.0.0.0/16' `
        ($vnet.addressSpace.addressPrefixes -contains '10.0.0.0/16')

    $subnetNames = $vnet.subnets | ForEach-Object { $_.name }
    Write-Check "Subnet 'snet-web' exists"  ($subnetNames -contains 'snet-web')
    Write-Check "Subnet 'snet-app' exists"  ($subnetNames -contains 'snet-app')
    Write-Check "Subnet 'snet-data' exists" ($subnetNames -contains 'snet-data')

    $webSubnet  = $vnet.subnets | Where-Object { $_.name -eq 'snet-web' }
    $appSubnet  = $vnet.subnets | Where-Object { $_.name -eq 'snet-app' }
    $dataSubnet = $vnet.subnets | Where-Object { $_.name -eq 'snet-data' }

    if ($webSubnet)  { Write-Check 'snet-web  prefix is 10.0.1.0/24' ($webSubnet.addressPrefix  -eq '10.0.1.0/24') }
    if ($appSubnet)  { Write-Check 'snet-app  prefix is 10.0.2.0/24' ($appSubnet.addressPrefix  -eq '10.0.2.0/24') }
    if ($dataSubnet) { Write-Check 'snet-data prefix is 10.0.3.0/24' ($dataSubnet.addressPrefix -eq '10.0.3.0/24') }
}

# Check 3: Tags
Write-Host ''
Write-Host '[3/3] Checking resource tags...' -ForegroundColor White
if ($null -ne $vnet) {
    Write-Check "VNet tagged with lab='azure-networking-labs'" ($vnet.tags.lab -eq 'azure-networking-labs')
    Write-Check 'VNet has session key tag (required for unlock code)' (-not [string]::IsNullOrEmpty($vnet.tags.sessionKey))
}

# Result
Write-Host ''
Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    $sessionKey = $vnet.tags.sessionKey
    if ([string]::IsNullOrEmpty($sessionKey)) {
        Write-Host '[ERROR] Session key tag not found. Re-deploy the module:' -ForegroundColor Red
        Write-Host "        az deployment group create --resource-group $ResourceGroupName --template-file deploy.bicep" -ForegroundColor Yellow
        exit 1
    }
    $unlockCode = "ANL-MOD01-$sessionKey-COMPLETE"
    $padding = '-' * ($unlockCode.Length + 4)
    $border  = "  +$padding+"
    Write-Host '  ALL CHECKS PASSED!' -ForegroundColor Green
    Write-Host ''
    Write-Host '  Your Module 01 unlock code:' -ForegroundColor White
    Write-Host ''
    Write-Host $border   -ForegroundColor Yellow
    Write-Host "  |  $unlockCode  |" -ForegroundColor Yellow
    Write-Host $border   -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  Copy this code and paste it into the learning portal.' -ForegroundColor White
    Write-Host '  Module 02 (NSGs) will unlock once you submit it.' -ForegroundColor White
} else {
    Write-Host '  VALIDATION FAILED' -ForegroundColor Red
    Write-Host ''
    Write-Host '  Review the [FAIL] lines above, fix the issues, and re-run:' -ForegroundColor Yellow
    Write-Host "  az deployment group create --resource-group $ResourceGroupName --template-file deploy.bicep" -ForegroundColor Yellow
}
Write-Host '=================================================' -ForegroundColor Cyan
Write-Host ''
