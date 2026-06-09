#Requires -Version 5.1
<#
.SYNOPSIS  Validates Module 07: Fault Lab - Routing fix.
.DESCRIPTION
    Checks that the route-to-internet route in rt-web-fault has been corrected
    to use 'Internet' as the next-hop type.
.PARAMETER ResourceGroupName  Default: rg-azure-networking-labs
#>
param([string]$ResourceGroupName = 'rg-azure-networking-labs')

$ErrorActionPreference = 'Continue'
$allPassed = $true

function Write-Check {
    param([string]$Description, [bool]$Passed)
    if ($Passed) { Write-Host "  [PASS] $Description" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $Description" -ForegroundColor Red; $script:allPassed = $false }
}

Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
Write-Host '  Module 07: Fault Lab Routing -- Validator' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Host '[ERROR] az not found.' -ForegroundColor Red; exit 1 }

Write-Host '[1/2] Checking route table exists...' -ForegroundColor White
$rt = az network route-table show --resource-group $ResourceGroupName --name 'rt-web-fault' 2>$null | ConvertFrom-Json
Write-Check "Route table 'rt-web-fault' exists" ($null -ne $rt)

if ($null -ne $rt) {
    Write-Host '' ; Write-Host '[2/2] Checking route-to-internet is fixed...' -ForegroundColor White
    $internetRoute = $rt.routes | Where-Object { $_.name -eq 'route-to-internet' }
    Write-Check "Route 'route-to-internet' exists" ($null -ne $internetRoute)
    if ($internetRoute) {
        $nhType = $internetRoute.properties.nextHopType
        Write-Check "Next-hop type is 'Internet' (was 'None')" ($nhType -eq 'Internet')
        if ($nhType -eq 'None') {
            Write-Host "  [TIP] The route is still set to 'None'. Run:" -ForegroundColor Yellow
            Write-Host "        az network route-table route update --resource-group $ResourceGroupName --route-table-name rt-web-fault --name route-to-internet --next-hop-type Internet" -ForegroundColor Yellow
        }
    }
}

Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    Write-Host '  ALL CHECKS PASSED! Routing fault fixed.' -ForegroundColor Green ; Write-Host ''
    Write-Host '  +---------------------------------------+' -ForegroundColor Yellow
    Write-Host '  |  ANL-MOD07-FAULT-ROUTING-COMPLETE     |' -ForegroundColor Yellow
    Write-Host '  +---------------------------------------+' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  Congratulations! You have completed all 7 modules.' -ForegroundColor Green
    Write-Host '  Check the portal for your full completion status.' -ForegroundColor White
} else {
    Write-Host '  NOT FIXED YET -- check the hints in README.md.' -ForegroundColor Red
}
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
