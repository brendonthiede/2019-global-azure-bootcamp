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

1. Connect to Azure:

```powershell
Connect-AzAccount | Out-Null
```

2. List your subscriptions:

```powershell
Get-AzSubscription
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
