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

Write-Verbose "Installing Application dependencies"
Set-Location $PSScriptRoot/Application
npm install

Write-Verbose "Installing Tests dependencies"
Set-Location $PSScriptRoot/Tests
npm install

Write-Verbose "Running Unit Tests"
Set-Location $PSScriptRoot/Tests
./node_modules/.bin/gulp unittest
if ($LASTEXITCODE -ne 0) {
    throw "Unit tests failed"
}

Write-Verbose "Packaging application code"
$distFolder = "$PSScriptRoot/dist"
$zipFilePath = "$distFolder/application.zip"
$appFolder = "$PSScriptRoot/Application"
New-Item -Path $distFolder -ItemType Directory -ErrorAction SilentlyContinue -Force
Compress-Archive -Path "$appFolder/*" -DestinationPath $zipFilePath -Force

$randomPassword = (Get-BootcampRandomPassword)
$myIP = (Invoke-RestMethod https://ipinfo.io/ip).Trim()
$sqlServerAdminGroup = (New-BootcampSQLServerAdminGroup)

$templateParameters = @{
    "webAppNamePrefix"  = "$webAppNamePrefix"
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

$siteUrl = "https://$($outputs.defaultHostName.value)"
Write-Verbose "Waiting for $siteUrl to be available before code deployment"
Set-Location $PSScriptRoot/Tests
./node_modules/.bin/wait-on $siteUrl

New-BootcampWebAppDeployment `
    -ZipFilePath $zipFilePath `
    -WebAppName $outputs.webAppName.value `
    -ResourceGroupName $ResourceGroupName `
    -Verbose:$VerbosePreference

$siteUrl = "https://$($outputs.defaultHostName.value)"
Write-Verbose "Waiting for $siteUrl to be available after code deployment"
Set-Location $PSScriptRoot/Tests
./node_modules/.bin/wait-on $siteUrl

Write-Verbose "Running functional tests against $siteUrl"
Set-Location $PSScriptRoot/Tests
./node_modules/.bin/gulp functionaltest --webAppUrl "$siteUrl"
if ($LASTEXITCODE -ne 0) {
    throw "Functional tests failed"
}

Pop-Location