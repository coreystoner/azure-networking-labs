#Requires -Version 5.1
<#
.SYNOPSIS  One-command deploy for Module 04: Routing & UDRs.
.EXAMPLE   .\Start-Module.ps1
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [string]$Location          = 'eastus',
    [switch]$SkipValidation,
    [switch]$Force
)
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
& "$root\Start-Lab.ps1" -Module '04' `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SkipValidation:$SkipValidation `
    -Force:$Force
