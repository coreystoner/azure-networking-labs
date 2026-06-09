#Requires -Version 5.1
<#
.SYNOPSIS
    Removes all Azure Networking Lab resources.
.DESCRIPTION
    Deletes the resource group and all resources within it.
    This affects ALL modules since they share a resource group.
    Use the -ModuleOnly switch to keep the resource group but remove only
    Module 01 resources (the hub VNet).
.PARAMETER ResourceGroupName
    Default: rg-azure-networking-labs
.PARAMETER ModuleOnly
    If specified, removes only the VNet deployed by this module,
    leaving the resource group and other module resources intact.
.PARAMETER Force
    Skip the confirmation prompt.
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [switch]$ModuleOnly,
    [switch]$Force
)

Write-Host ''
Write-Host 'Azure Networking Labs -- Module 01 Cleanup' -ForegroundColor Cyan
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host ''

if ($ModuleOnly) {
    Write-Host "This will delete only 'vnet-hub' from: $ResourceGroupName" -ForegroundColor Yellow
} else {
    Write-Host "This will delete the ENTIRE resource group: $ResourceGroupName" -ForegroundColor Yellow
    Write-Host 'All resources from all modules will be removed.' -ForegroundColor Yellow
}
Write-Host ''

if (-not $Force) {
    $confirm = Read-Host "Type 'yes' to confirm"
    if ($confirm -ne 'yes') {
        Write-Host 'Cancelled.' -ForegroundColor Green
        exit 0
    }
}

if ($ModuleOnly) {
    Write-Host "Deleting VNet 'vnet-hub'..." -ForegroundColor White
    az network vnet delete --resource-group $ResourceGroupName --name 'vnet-hub'
    Write-Host '[DONE] VNet deleted.' -ForegroundColor Green
} else {
    Write-Host "Deleting resource group '$ResourceGroupName'..." -ForegroundColor White
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Deletion initiated (runs in background, ~2-5 min).' -ForegroundColor Green
    Write-Host "[TIP]  Check status: az group exists --name $ResourceGroupName" -ForegroundColor Cyan
}
Write-Host ''
