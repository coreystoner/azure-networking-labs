#Requires -Version 5.1
param([string]$ResourceGroupName = 'rg-azure-networking-labs', [switch]$ModuleOnly, [switch]$Force)

Write-Host 'Module 03 Cleanup' -ForegroundColor Cyan
if (-not $Force) { $c = Read-Host "Type 'yes' to confirm"; if ($c -ne 'yes') { exit 0 } }

if ($ModuleOnly) {
    az network vnet peering delete --resource-group $ResourceGroupName --vnet-name 'vnet-hub' --name 'peer-hub-to-spoke1'
    az network vnet peering delete --resource-group $ResourceGroupName --vnet-name 'vnet-spoke1' --name 'peer-spoke1-to-hub'
    az network vnet delete --resource-group $ResourceGroupName --name 'vnet-spoke1'
    Write-Host '[DONE] Module 03 resources removed.' -ForegroundColor Green
} else {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Resource group deletion initiated.' -ForegroundColor Green
}
