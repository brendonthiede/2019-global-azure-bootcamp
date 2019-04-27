[CmdletBinding()]
param (
    [ValidateLength(0, 11)]
    [string]
    $StorageAccountPrefix = "bootcamp",

    [string]
    $ContainerName = "`$web",

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

$outputs = (New-BootcampResourceGroupDeployment `
        -TemplateFile $PSScriptRoot/autodeploy.json `
        -TemplateParameterObject @{"storageAccountPrefix" = "$StorageAccountPrefix"; "containerName" = "$ContainerName"} `
        -DeploymentName $DeploymentName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Force:$Force `
        -Verbose:$VerbosePreference).Outputs

New-BootcampBlobDeployment `
    -FolderToUpload "$PSScriptRoot/site" `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $outputs.storageAccountName.Value `
    -ContainerName $ContainerName `
    -Verbose:$VerbosePreference
