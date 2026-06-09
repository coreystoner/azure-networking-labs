#Requires -Version 5.1
<#
.SYNOPSIS  One-command deploy for Module 01: VNets & Subnets.
.EXAMPLE   .\Start-Module.ps1
.EXAMPLE   .\Start-Module.ps1 -Location westus2
#>
param(
    [string]$ResourceGroupName = 'rg-azure-networking-labs',
    [string]$Location          = 'eastus',
    [switch]$SkipValidation,
    [switch]$Force
)
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
& "$root\Start-Lab.ps1" -Module '01' `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SkipValidation:$SkipValidation `
    -Force:$Force
