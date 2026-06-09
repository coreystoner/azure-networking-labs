#Requires -Version 5.1
param([string]$ResourceGroupName = 'rg-azure-networking-labs', [switch]$ModuleOnly, [switch]$Force)
Write-Host 'Module 04 Cleanup' -ForegroundColor Cyan
if (-not $Force) { $c = Read-Host "Type 'yes' to confirm"; if ($c -ne 'yes') { exit 0 } }
if ($ModuleOnly) {
    foreach ($rt in @('rt-web', 'rt-app', 'rt-data')) {
        az network route-table delete --resource-group $ResourceGroupName --name $rt
    }
    Write-Host '[DONE] Route tables removed.' -ForegroundColor Green
} else {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host '[DONE] Resource group deletion initiated.' -ForegroundColor Green
}
