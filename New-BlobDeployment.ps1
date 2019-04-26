[CmdletBinding()]
param (
    [string]
    $FolderToUpload,

    [string]
    $ResourceGroupName,

    [string]
    $StorageAccountName,

    [string]
    $ContainerName
)

$ErrorActionPreference = "Stop"

function GetMimeType ($fileExtension) {
    switch ($fileExtension) {
        ".html" { $mimeType = "text/html" }
        ".css" { $mimeType = "text/css" }
        ".js" { $mimeType = "text/javascript" }
        ".png" { $mimeType = "image/png" }
        ".jpg" { $mimeType = "image/jpeg" }
        ".gif" { $mimeType = "image/gif" }
        Default { $mimeType = "application/octet-stream" }
    }

    return $mimeType
}

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

Get-ChildItem $FolderToUpload | ForEach-Object {
    Write-Verbose "Uploading $($_.Name)"
    Set-AzStorageBlobContent -File $_.FullName `
        -Blob $_.Name `
        -Context $storageAccount.Context `
        -Container $ContainerName `
        -Properties @{"ContentType" = GetMimeType($_.Extension)} `
        -Force
}
