#Requires -Version 5.1
<#
.SYNOPSIS  Removes Module 05 Azure Firewall resources.
.PARAMETER ModuleOnly  Remove only the firewall (not the whole resource group).
.PARAMETER Force  Skip confirmation.
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [switch]$ModuleOnly,
    [switch]$Force
)

Write-Host ''
Write-Host 'Module 05 Cleanup -- Azure Firewall' -ForegroundColor Cyan
Write-Host '====================================' -ForegroundColor Cyan
Write-Host ''

if (-not $Force) {
    $confirm = Read-Host "Type 'yes' to confirm deletion"
    if ($confirm -ne 'yes') { Write-Host 'Cancelled.'; exit 0 }
}

if ($ModuleOnly) {
    Write-Host 'Step 1/4: Deleting Azure Firewall (takes 2-4 min)...' -ForegroundColor White
    az network firewall delete --resource-group $ResourceGroupName --name 'afw-hub'
    Write-Host 'Step 2/4: Deleting Firewall Policy...' -ForegroundColor White
    az network firewall policy delete --resource-group $ResourceGroupName --name 'afwp-hub'
    Write-Host 'Step 3/4: Deleting Public IP...' -ForegroundColor White
    az network public-ip delete --resource-group $ResourceGroupName --name 'pip-afw-hub'
    Write-Host 'Step 4/4: Deleting AzureFirewallSubnet...' -ForegroundColor White
    az network vnet subnet delete --resource-group $ResourceGroupName --vnet-name 'vnet-hub' --name 'AzureFirewallSubnet'
    Write-Host '[DONE] Azure Firewall resources removed.' -ForegroundColor Green
} else {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Resource group deletion initiated.' -ForegroundColor Green
}
Write-Host ''
