[CmdletBinding()]
param (
    [string]
    $TemplateFile,

    [hashtable]
    $TemplateParameterObject = $null,

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

$subscription = (Get-AzContext)

if (-not $subscription) {
    throw "You must connect to a subscription first with Connect-AzAccount and Set-AzContext"
}

if (-not $Force) {
    Write-Host "Ready to deploy resources to the $ResourceGroupName resource group in the $($subscription.Subscription.Name) subscription ($Location location)"
    Write-Host "Continue? (Y/N)"
    $keyPress = $null
    $keyOption = 'Y', 'N'
    while ($keyOption -notcontains $keyPress.Character) {
        $keyPress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    if ($keyPress.Character -ne 'Y') {
        Write-Host "Aborting deployment"
        exit 1
    } else {
        Write-Host "Starting deployment"
    }
}

if (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue) {
    Write-Verbose "Resource group $ResourceGroupName already exists"
}
else {
    Write-Verbose "Creating resource group $ResourceGroupName in $Location region"
    $provisioningState = (New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force).ProvisioningState
    Write-Verbose "ProvisioningState: $provisioningState"
}

Write-Verbose "Deploying ARM template"
New-AzResourceGroupDeployment -Name $DeploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterObject $TemplateParameterObject `
    -Mode Incremental
