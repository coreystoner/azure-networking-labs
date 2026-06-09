#Requires -Version 5.1
<#
.SYNOPSIS  Removes Module 02 NSG resources (or the full resource group).
.PARAMETER ResourceGroupName  Default: rg-azure-networking-labs
.PARAMETER ModuleOnly  Remove only NSG resources from this module.
.PARAMETER Force  Skip confirmation prompt.
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [switch]$ModuleOnly,
    [switch]$Force
)

Write-Host 'Azure Networking Labs -- Module 02 Cleanup' -ForegroundColor Cyan

if (-not $Force) {
    $confirm = Read-Host "Type 'yes' to confirm deletion"
    if ($confirm -ne 'yes') { Write-Host 'Cancelled.'; exit 0 }
}

if ($ModuleOnly) {
    Write-Host 'Removing NSGs...' -ForegroundColor White
    foreach ($nsg in @('nsg-web', 'nsg-app', 'nsg-data')) {
        az network nsg delete --resource-group $ResourceGroupName --name $nsg
        Write-Host "  Deleted $nsg" -ForegroundColor Gray
    }
    Write-Host '[DONE]' -ForegroundColor Green
} else {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Resource group deletion initiated.' -ForegroundColor Green
}
