[CmdletBinding()]
param (
    [ValidateLength(0, 11)]
    [string]
    $StorageAccountPrefix = "bootcamp2",

    [string]
    $AppContainerName = "`$web",

    [string]
    $ImageContainerName = "images",

    [string]
    $ThumbnailsContainerName = "thumbnails",

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
Set-Location $PSScriptRoot/www
npm install
npm run generate

$templateParameters = @{
    "storageAccountPrefix" = "$StorageAccountPrefix"
    "appContainerName"     = "$AppContainerName"
    "imageContainerName"   = "$ImageContainerName"
    "thumbnailsContainerName"   = "$ThumbnailsContainerName"
}

$outputs = (New-BootcampResourceGroupDeployment `
        -TemplateFile $PSScriptRoot/autodeploy.json `
        -TemplateParameterObject $templateParameters `
        -DeploymentName $DeploymentName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Force:$Force `
        -Verbose:$VerbosePreference).Outputs

$CorsRules = (@{
        AllowedHeaders  = @("*")
        AllowedOrigins  = @("*")
        ExposedHeaders  = @("*")
        MaxAgeInSeconds = 30
        AllowedMethods  = @("Options", "Put")
    })

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $outputs.storageAccountName.Value
Set-AzStorageCORSRule -ServiceType Blob -CorsRules $CorsRules -Context $storageAccount.Context

"window.apiBaseUrl = 'https://$($outputs.defaultHostName.Value)'" | Set-Content  "$PSScriptRoot/www/dist/settings.js" -Force
"window.blobBaseUrl = '$($outputs.storageAccountBlobEndpoint.Value.trim('/'))'" | Add-Content "$PSScriptRoot/www/dist/settings.js"
"window.authEnabled = false" | Add-Content "$PSScriptRoot/www/dist/settings.js"

"storageAccountBlobEndpoint"
New-BootcampBlobDeployment `
    -FolderToUpload "$PSScriptRoot/www/dist" `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $outputs.storageAccountName.Value `
    -ContainerName $AppContainerName `
    -Verbose:$VerbosePreference
    
New-BootcampBlobDeployment `
    -FolderToUpload "$PSScriptRoot/www/dist/nuxt" `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $outputs.storageAccountName.Value `
    -ContainerName $AppContainerName `
    -BlobPrefix "nuxt/" `
    -Verbose:$VerbosePreference
    
Pop-Location
