# 2019 Global Azure Bootcamp

Code samples for the [2019 Global Azure Bootcamp](https://www.digestibledevops.com/devops/2019/03/27/global-azure-bootcamp.html), presented by Lansing Codes and the Lansing DevOps Meetup.

## Stages

### Storage Account

### Web App (App Insights)

### Web App with Azure Database

### Web App wih Cosmos DB

### Function App (storage)

### Web App, Function App, Storage, and Cosmos DB

## Running PowerShell Scripts

In order to run unsigned scripts on Windows, you can run the following:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

## Deploying a Template

### Connecting to a subscription

Here are some PowerShell commands to get you connected to a subscription:

```powershell
# Connect to Azure:
(Connect-AzAccount).Subscription.Name

# Show current subscription:
(Get-AzContext).Subscription.Name

# List your subscriptions:
Get-AzSubscription | Select-Object -Property Name

# Switch to a different subscription ("Visual Studio Enterprise" in this case):
(Set-AzContext -Subscription "Visual Studio Enterprise").Subscription.Name
```

### Creating a Resource Group

You need to create a resource group before you can deploy to it. This is an example of a resource group named "bootcamp-rg" in the "East US" region:

```powershell
(New-AzResourceGroup -Name bootcamp-rg -Location eastus -Force).ProvisioningState
```

### Deploying the ARM Template

Provide any required parameters either through the command line or using a parameters file:

```powershell
$DeploymentName = "$(Get-Date -Format "yyyyMMddHHmmss")$env:COMPUTERNAME"
New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName bootcamp-rg -Mode Incremental -TemplateFile .\stage-01\autodeploy.json
```

## System Prerequisite Notes

### Installing Git, Node 10, and Dev Tools on Ubuntu 18.04

```bash
sudo apt-get install git
sudo apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y gcc g++ make

```

### Git Config

When first setting up git, you will need to configure your username and email:

```powershell
git config --global user.name "yourusername"
git config --global user.email "youremail@mail.com"
```

On Linux or a Mac you may want to set up an SSH key to automatically authenticate you:

```bash
ssh-keygen -t rsa -b 4096 -C "youremail@mail.com"
```

If you use the defaults you can grab the public key like this:

```bash
cat /home/brendon/.ssh/id_rsa.pub
```

And then add that to your GitHub account at [https://github.com/settings/ssh/new](https://github.com/settings/ssh/new)

### Installing PowerShell on Ubuntu

```bash
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo add-apt-repository universe
sudo apt-get install -y powershell
```

### Setting PowerShell as the Default Shell

On Ubuntu, to set PowerShell as the default shell, run the following and then logout and log back in (just starting a new shell is not enough):

```powershell
chsh -s /usr/bin/pwsh $USER
```

### Installing Az Modules

From a PowerShell prompt, run:

```powershell
Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

### Installing ChromeDriver

Install ChromeDriver from [http://chromedriver.storage.googleapis.com/index.html](http://chromedriver.storage.googleapis.com/index.html) by downloading the latest zip file for your operating system and then putting the executable from the zip into your path.

Example for Windows:

```powershell
Invoke-WebRequest "http://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_win32.zip" -OutFile chromedriver_win32.zip
Expand-Archive -Path .\chromedriver_win32.zip -DestinationPath $env:USERPROFILE\bin
$systemPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User') + ";$env:USERPROFILE\bin" -replace ';;',';'
[System.Environment]::SetEnvironmentVariable('PATH', $systemPath, 'User')
$env:PATH += ";$env:USERPROFILE\bin"
```

