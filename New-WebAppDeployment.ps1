[CmdletBinding()]
param (
    [string]
    $ZipFilePath,

    [string]
    $WebAppName = $null,

    [string]
    $ResourceGroupName = "bootcamp-rg"
)

Write-Verbose "Pulling deployment URLs and credentials"
if (-not $WebAppName) {
    $WebAppName = (Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType 'Microsoft.Web/sites')[0].Name
}
$publishProfile = ([xml](Get-AzWebAppPublishingProfile -ResourceGroupName $ResourceGroupName  -Name $WebAppName)).publishData.publishProfile[0]
$webApp = (Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName)
$apiDomain = $webApp.EnabledHostNames | Where-Object { $_ -like '*.scm.*' }

$username = "$($publishProfile.userName)"
$password = "$($publishProfile.userPWD)"
$apiUrl = "https://$apiDomain/api/zipdeploy"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
$userAgent = "powershell/1.0"

Write-Verbose "Deploying application bundle"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)} -UserAgent $userAgent -Method POST -InFile $ZipFilePath -ContentType "multipart/form-data"
