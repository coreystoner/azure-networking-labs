#Requires -Version 5.1
<#
.SYNOPSIS  One-command deploy for Module 05: Azure Firewall.
.DESCRIPTION
    IMPORTANT: Azure Firewall costs ~$1.25-1.50/hr.
    Run cleanup.ps1 -ModuleOnly immediately after validating.
.EXAMPLE   .\Start-Module.ps1
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [string]$Location          = 'eastus',
    [switch]$SkipValidation,
    [switch]$Force
)
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
& "$root\Start-Lab.ps1" -Module '05' `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SkipValidation:$SkipValidation `
    -Force:$Force
