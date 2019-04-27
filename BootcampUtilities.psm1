function Test-BootcampLogin {
    $subscription = (Get-AzContext)

    if (-not $subscription) {
        throw "You must connect to a subscription first with Connect-AzAccount and Set-AzContext"
    }
}

function New-BootcampResourceGroupDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]
        $TemplateFile,

        [Parameter(Mandatory = $True)]
        [hashtable]
        $TemplateParameterObject,

        [Parameter(Mandatory = $True)]
        [string]
        $DeploymentName,

        [Parameter(Mandatory = $True)]
        [string]
        $ResourceGroupName,

        [Parameter(Mandatory = $True)]
        [string]
        $Location,

        [Parameter(Mandatory = $False)]
        [switch]
        $Force
    )

    Test-BootcampLogin

    if (-not $Force) {
        Write-Host "Ready to deploy resources to the $ResourceGroupName resource group in the $Location region"
        Write-Host "Continue? (Y/N)"
        $keyPress = $null
        $keyOption = 'Y', 'N'
        while ($keyOption -notcontains $keyPress.Character) {
            $keyPress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        if ($keyPress.Character -ne 'Y') {
            Write-Host "Aborting deployment"
            exit 1
        }
        else {
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
        -Mode Incremental `
        -Verbose:$VerbosePreference
}

function New-BootcampBlobDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]
        $FolderToUpload,
    
        [Parameter(Mandatory = $True)]
        [string]
        $ResourceGroupName,
    
        [Parameter(Mandatory = $True)]
        [string]
        $StorageAccountName,
    
        [Parameter(Mandatory = $True)]
        [string]
        $ContainerName,

        [Parameter(Mandatory = $False)]
        [string]
        $BlobPrefix = ""
    )

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    
    Get-ChildItem $FolderToUpload | ForEach-Object {
        switch ($_.Extension) {
            ".html" { $mimeType = "text/html" }
            ".css" { $mimeType = "text/css" }
            ".js" { $mimeType = "text/javascript" }
            ".png" { $mimeType = "image/png" }
            ".jpg" { $mimeType = "image/jpeg" }
            ".gif" { $mimeType = "image/gif" }
            ".txt" { $mimeType = "text/plain" }
            ".md" { $mimeType = "text/plain" }
            ".ico" { $mimeType = "image/x-icon" }
            Default { $mimeType = "application/octet-stream" }
        }

        Write-Verbose "Uploading $($_.Name) as $mimeType to $StorageAccountName/$ContainerName"
        Set-AzStorageBlobContent -File $_.FullName `
            -Blob "$($BlobPrefix)$($_.Name)" `
            -Context $storageAccount.Context `
            -Container $ContainerName `
            -Properties @{"ContentType" = $mimeType} `
            -Force
    }
}

function Get-BootcampRandomPassword {
    [cmdletbinding()]
    [OutputType([String])]
    param(    
        [Parameter(Mandatory = $False)]
        [Int]
        $PasswordLength = 128,
    
        [Parameter(Mandatory = $False)]
        [switch]
        $IncludeUpperCase,

        [Parameter(Mandatory = $False)]
        [switch]
        $IncludeLowerCase,

        [Parameter(Mandatory = $False)]
        [switch]
        $IncludeNumbers,

        [Parameter(Mandatory = $False)]
        [switch]
        $IncludeSpecialCharacters,

        [Parameter(Mandatory = $False)]
        [String]
        $SpecialCharacters = "!@#$%^&*()_+"
    )

    function GetRandomCharacter() {
        param([Parameter(Mandatory = $True)][string]$characterSet)
        if ($characterSet.Length -eq 1) {
            return $characterSet[0]
        }
        return $characterSet.ToCharArray()[(Get-Random -Minimum 0 -Maximum ($characterSet.Length - 1))]
    }

    $allowedCharacters = ""
    $password = ""

    # Set default password rules to alphanumeric if nothing was explicitly set
    if (!$IncludeUpperCase -and !$IncludeLowerCase -and !$IncludeNumbers -and !$IncludeSpecialCharacters) {
        $IncludeUpperCase = $true
        $IncludeLowerCase = $true
        $IncludeNumbers = $true
    }

    if ($IncludeUpperCase) {
        $upperCaseCharacters = ([char[]]([char]65..[char]90) -join '')
        $allowedCharacters += $upperCaseCharacters
        $password += GetRandomCharacter $upperCaseCharacters
        $PasswordLength -= 1
    }
    if ($IncludeLowerCase) {
        $lowerCaseCharacters = ([char[]]([char]97..[char]122) -join '')
        $allowedCharacters += $lowerCaseCharacters
        $password += GetRandomCharacter $lowerCaseCharacters
        $PasswordLength -= 1
    }
    if ($IncludeNumbers) {
        $numberCharacters = ((0..9) -join '')
        $allowedCharacters += $numberCharacters
        $password += GetRandomCharacter $numberCharacters
        $PasswordLength -= 1
    }
    if ($IncludeSpecialCharacters) {
        if ($SpecialCharacters.Length -eq 0) {
            throw "Cannot include special character with empty special character set"
        }
        $allowedCharacters += $SpecialCharacters
        $password += GetRandomCharacter $SpecialCharacters
        $PasswordLength -= 1
    }

    For ($i = 0; $i -lt $PasswordLength; $i++) {
        $password += GetRandomCharacter $allowedCharacters
    }

    $password
}

function New-BootcampWebAppDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]
        $ZipFilePath,

        [Parameter(Mandatory = $True)]
        [string]
        $WebAppName,

        [Parameter(Mandatory = $True)]
        [string]
        $ResourceGroupName
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
}

function New-BootcampSQLServerAdminGroup {
    [CmdletBinding()]
    param (
        [string]
        $SQLServerAdminGroupName = "SQLServerAdmins",

        [string]
        $SQLServerAdminGroupMailNickname = "SQLServerAdminGroup"
    )

    if (-not (Get-AzADGroup -DisplayName "$SQLServerAdminGroupName" -ErrorAction SilentlyContinue)) {
        Write-Verbose "Creating new Azure AD group for $SQLServerAdminGroupName"
        New-AzADGroup -DisplayName "$SQLServerAdminGroupName" -MailNickname "$SQLServerAdminGroupMailNickname"
    }
    (Get-AzADGroup -DisplayName "$SQLServerAdminGroupName")[0]
}

Export-ModuleMember -Function *