---
slug: homelab-day-2
title: (Day 2) Deploying Active Directory Domain Service on HV01
author: Vo Luu Tuong Anh
author_title: VLTA of @TheFlightSims
author_url: https://github.com/anhvlttfs
author_image_url: https://avatars.githubusercontent.com/u/176574466?v=4
tags: [homelab, local-networking, active-directory]
---

This is the day two of **TheFlightSims Challenge** - A 10-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

## Setup Active Directory Domain Service on domain controllers

After completing setup on HV01, I tried to install Windows Server 2022 Datacenter Core, with Domain Service roles.

The requirements for the setup is:

- Domain: `workshop.neko`
- Roles installed: Active Directory Domain Services and DNS Server
- IPv4 addresses: `192.168.1.10` for DC01 and `192.168.1.11` for DC02

> I would recommend using a deployment template in case a massive deployment like deploying domain controllers for a network like this case. You can review [Domain Controller template here](/homelab-setup-day-2/DomainController_DeploymentConfigTemplate.xml)
>
> You can automate the installation process by using Powershell command in Windows Server:
>
> ```powershell
> Install-WindowsFeature -ConfigurationFilePath ".\DomainController_DeploymentConfigTemplate.xml"
> ```

After installing roles for the domain controllers, it is recommend to run a quick check before promoting computer to domain controller

```powershell
# Run network check
$isNetworkValidated = $false
$networkStatus = Test-NetConnection -ComputerName google.com
if ($networkStatus.PingSucceeded -eq $true) {
    Write-Host "Internet connection is validated!"
    $isNetworkValidated = $true
} else {
    Write-Host "No Internet connection! Additional Setup may require Internet connection!" -ForegroundColor Red
}

# Get Windows Activation status
$isWSActivated = $false
$wsStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus
if ($wsStatus.LicenseStatus -eq 1) {
    $isWSActivated = $true
    Write-Host "Windows is activated!"
} else {
    Write-Host "Windows is not activated!" -ForegroundColor Red
}

# Get Windows image status
$isImageGood = $false
$wsImage = Repair-WindowsImage -Online -CheckHealth
if ($wsImage.ImageHealthState -eq "Healthy") {
    Write-Host "Windows Image is in good condition!" 
    $isImageGood = $true
} else {
    Write-Host "Windows Image is currupted! You should run diagnostic!" -ForegroundColor Red
}

if ($isNetworkValidated -and $isWSActivated -and $isImageGood) {
    Write-Host "Your Windows instance can be promoted to Domain Controller"
} else {
    Write-Host "Your Windows instance should not be promoted to Domain Controller" -ForegroundColor Red
}

```

![Run Prequisites (DC01)](/homelab-setup-day-2/run-prequisites-dc01.png)
