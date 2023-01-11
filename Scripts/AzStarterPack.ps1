<#
    .SYNOPSIS
    Deploy all base tools on a new workstation
    
    .DESCRIPTION  
    This script will install all the required tools to get up and running as soon as possible without having to manually install the tools of the trade.
   
    .LINK
     
    .NOTES
   
#>
# Visual Studio Code
winget install Microsoft.VisualStudioCode

# Azure Tools
winget install Microsoft.AzureStorageExplorer
winget install Microsoft.Bicep
winget install Microsoft.AzureCLI

# PowerShell 7
winget install Microsoft.PowerShell

# Windows Terminal (if on Windows 10)
winget install Microsoft.WindowsTerminal

# Git and GitHub CLI
winget install Git.Git
winget install GitHub.cli
git config --global user.name "Darren Turchiarelli"
git config --global user.email dturchiarelli@hotmail.com

# Azure PowerShell
pwsh (Make sure to start your terminal session with PowerShell 7)
Install-Module Az

# Azure Tables PS Module 
Install-Module -Name AzTable

# Visual Code Extensions

code --install-extension eamodio.gitlens
code --install-extension telesoho.vscode-markdown-paste-image
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension AzurePolicy.azurepolicyextension
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-azurestorage
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-azureterraform
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.remote-ssh-explorer
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension ms-vsonline.vsonline
code --install-extension msazurermtools.azurerm-vscode-tools
code --install-extension ms-mssql.mssql
code --install-extension christian-kohler.path-intellisense
code --install-extension esbenp.prettier-vscode

# Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Hugo
choco install hugo -confirm

# AzCopy
Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing
Expand-Archive ./AzCopy.zip ./AzCopy -Force
mkdir "$home/AzCopy"
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination "$home\AzCopy\AzCopy.exe"
$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $userenv + ";$home\AzCopy", "User")

#Helm 
choco install kubernetes-helm

#Kubernetes - kubectl 
choco install kubernetes-cli

#Kubectx power tools https://github.com/ahmetb/kubectx#installation 
choco install kubens kubectx

#Postman
winget install -e --id Postman.Postman

#Wireshark
winget install WiresharkFoundation.Wireshark

#7ZIP
winget install 7zip.7zip

#To keep things up to date run:
#winget upgrade --all
