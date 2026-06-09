#Requires -Version 5.1
param([string]$ResourceGroupName = 'rg-azure-networking-labs', [switch]$ModuleOnly, [switch]$Force)
Write-Host 'Module 07 Cleanup' -ForegroundColor Cyan
if (-not $Force) { $c = Read-Host "Type 'yes' to confirm"; if ($c -ne 'yes') { exit 0 } }
if ($ModuleOnly) {
    az network vnet subnet delete --resource-group $ResourceGroupName --vnet-name 'vnet-hub' --name 'snet-web-fault2'
    az network route-table delete --resource-group $ResourceGroupName --name 'rt-web-fault'
    Write-Host '[DONE] Module 07 resources removed.' -ForegroundColor Green
} else {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Resource group deletion initiated.' -ForegroundColor Green
}
