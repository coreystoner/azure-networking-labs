#Requires -Version 5.1
<#
.SYNOPSIS  Validates Module 06: Fault Lab - NSG fix.
.DESCRIPTION
    Checks that the Block-All-Inbound rule in nsg-web-fault has been moved
    to a priority higher than Allow-HTTP-Inbound (priority 100).
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
Write-Host '  Module 06: Fault Lab NSG -- Validator' -ForegroundColor Cyan
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-Host '[ERROR] az not found.' -ForegroundColor Red; exit 1 }

Write-Host '[1/3] Checking NSG exists...' -ForegroundColor White
$nsg = az network nsg show --resource-group $ResourceGroupName --name 'nsg-web-fault' 2>$null | ConvertFrom-Json
Write-Check "NSG 'nsg-web-fault' exists" ($null -ne $nsg)

if ($null -ne $nsg) {
    Write-Host '' ; Write-Host '[2/3] Checking Allow-HTTP rule...' -ForegroundColor White
    $allowHttp = $nsg.securityRules | Where-Object {
        $_.properties.access -eq 'Allow' -and
        $_.properties.direction -eq 'Inbound' -and
        $_.properties.destinationPortRange -eq '80'
    }
    Write-Check 'Allow-HTTP-Inbound rule exists' ($null -ne $allowHttp)

    Write-Host '' ; Write-Host '[3/3] Checking Block-All rule priority is HIGHER than Allow-HTTP...' -ForegroundColor White
    $blockAll = $nsg.securityRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        $_.properties.direction -eq 'Inbound' -and
        $_.properties.destinationPortRange -eq '*'
    }
    if ($null -ne $blockAll -and $null -ne $allowHttp) {
        $blockPriority = $blockAll.properties.priority
        $allowPriority = $allowHttp.properties.priority
        Write-Check "Block-All priority ($blockPriority) is GREATER than Allow-HTTP priority ($allowPriority)" `
            ($blockPriority -gt $allowPriority)
        Write-Check 'Allow-HTTP priority is <= 200 (reasonable value)' ($allowPriority -le 200)
    } elseif ($null -eq $blockAll) {
        Write-Host '  [INFO] Block-All rule not found (may have been deleted -- also acceptable)' -ForegroundColor Cyan
    }
}

Write-Host '' ; Write-Host '=================================================' -ForegroundColor Cyan
if ($allPassed) {
    Write-Host '  ALL CHECKS PASSED! Fault found and fixed.' -ForegroundColor Green ; Write-Host ''
    Write-Host '  +---------------------------------------+' -ForegroundColor Yellow
    Write-Host '  |  ANL-MOD06-FAULT-NSG-COMPLETE         |' -ForegroundColor Yellow
    Write-Host '  +---------------------------------------+' -ForegroundColor Yellow
    Write-Host '' ; Write-Host '  Enter this in the portal to unlock Module 07.' -ForegroundColor White
} else {
    Write-Host '  NOT FIXED YET -- check the hints in README.md.' -ForegroundColor Red
}
Write-Host '=================================================' -ForegroundColor Cyan ; Write-Host ''
