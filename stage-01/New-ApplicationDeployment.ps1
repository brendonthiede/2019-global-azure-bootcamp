[CmdletBinding()]
param (
    [ValidateLength(0, 11)]
    [string]
    $storageAccountPrefix = "azwkshp",

    [string]
    $containerName = "myfiles",

    [string]
    $DeploymentName = "$(Get-Date -Format "yyyyMMddHHmmss")$env:COMPUTERNAME",

    [string]
    $ResourceGroupName = "bootcamp-rg",

    [string]
    $Location = "eastus",

    [switch]
    $Force
)

& $PSScriptRoot/../New-StageResourceDeployment.ps1 `
    -TemplateFile $PSScriptRoot/autodeploy.json `
    -TemplateParameterObject @{"storageAccountPrefix" = "$storageAccountPrefix"; "containerName" = "$containerName"} `
    -DeploymentName $DeploymentName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Force:$Force `
    -Verbose:$VerbosePreference
