[CmdletBinding()]
param (
    [string]
    $webAppNamePrefix = "$env:USERNAME",

    [string]
    $DeploymentName = "$(Get-Date -Format "yyyyMMddHHmmss")$env:COMPUTERNAME",

    [string]
    $ResourceGroupName = "bootcamp-rg",

    [string]
    $Location = "eastus",

    [switch]
    $Force
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/../BootcampUtilities.psm1" -Force

trap {
    "Error found: $_"
    Pop-Location
}

Push-Location

$randomPassword = (Get-BootcampRandomPassword)
$myIP = (Invoke-RestMethod https://ipinfo.io/ip).Trim()
$sqlServerAdminGroup = (New-BootcampSQLServerAdminGroup)

$templateParameters = @{
    "sqlAdminPassword"  = "$randomPassword"
    "myIP"              = "$myIP"
    "AADAdminGroupName" = "$($sqlServerAdminGroup.DisplayName)"
    "AADAdminGroupId" = "$($sqlServerAdminGroup.Id)"
}

$outputs = (New-BootcampResourceGroupDeployment `
        -TemplateFile $PSScriptRoot/autodeploy.json `
        -TemplateParameterObject $templateParameters `
        -DeploymentName $DeploymentName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Force:$Force `
        -Verbose:$VerbosePreference).Outputs

Pop-Location