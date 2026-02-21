---
slug: homelab-day-3
title: (Day 3) Configure Active Directory Certification Services
author: Vo Luu Tuong Anh
author_title: VLTA of @TheFlightSims
author_url: https://github.com/anhvlttfs
author_image_url: https://avatars.githubusercontent.com/u/176574466?v=4
tags: [homelab, local-networking, active-directory]
---

This is the day three of **TheFlightSims Challenge** - A 10-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

# Configure Active Directory Certification Services

## Install & configure the root Certification Authority on DC01

To install AD CS Authority Service on DC01, to handle certification requests, you can use this [script to perform automated installation](/homelab-setup-day-3/Install-ADCS.ps1) on DC01

```powershell
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

if ($isWSActivated -and $isImageGood) {
    Write-Host "Installing AD CS roles for Domain Controller"
    Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools
} else {
    Write-Host "Unable to install AD CS for Domain Controller" -ForegroundColor Red
}
```

![AD CS installation on DC01](/homelab-setup-day-3/install-ad-cs-dc01.png)

Once the installation is finished, you can promote the AD CS of DC01 to the root authority, [using this script](/homelab-setup-day-3/Promote-RootADCS.ps1)

```powershell
# Check if the ADDS roles are installed
$isADCSInstalled = $false
$adcsRoleStatus = Get-WindowsFeature -Name "ADCS-Cert-Authority"
if ($adcsRoleStatus.InstallState -eq "Installed") {
    Write-Host "AD CS Services are installed!"
    $isADCSInstalled = $true
} else {
    Write-Host "AD CS Services are not installed!" -ForegroundColor Red
}

if ($isADCSInstalled) {
    Write-Host "Promoting current server to Root CA"
    Install-AdcsCertificationAuthority `
        -CAType EnterpriseRootCa `
        -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
        -KeyLength 4096 `
        -HashAlgorithmName SHA512 `
        -ValidityPeriod Years `
        -ValidityPeriodUnits 10
} else {
    Write-Host "Unable to install AD CS because of absent of Certificate Service installed" -ForegroundColor Red
}
```

![Promoting AD CS on DC01](/homelab-setup-day-3/promote-ad-cs-dc01.png)

## Install & configure the subroot Certification Authority on DC02

Once the promotion of the root CA on DC01 is completed, it is recommended to have a secondary Certification Authority on the Active Directory instance, so in case an authority service on a single server is crashed, you still can handle certification requests.

To do this, do the installation as same as on DC01, however, when promoting, you should try this [subroot CA promotion, not root CA promotion](/homelab-setup-day-3/Promote-SubRootADCS.ps1).

```powershell
$domain = "workshop.neko"
$caName = "workshop-DC01-CA"

# Check if the ADDS roles are installed
$isADCSInstalled = $false
$adcsRoleStatus = Get-WindowsFeature -Name "ADCS-Cert-Authority"
if ($adcsRoleStatus.InstallState -eq "Installed") {
    Write-Host "AD CS Services are installed!"
    $isADCSInstalled = $true
} else {
    Write-Host "AD CS Services are not installed!" -ForegroundColor Red
}

if ($isADCSInstalled) {
    Write-Host "Promoting current server to Subroot CA"
    Install-AdcsCertificationAuthority `
        -CAType EnterpriseSubordinateCa `
		-ParentCA "DC01.$domain\$caName"
} else {
    Write-Host "Unable to install AD CS because of absent of Certificate Service installed" -ForegroundColor Red
}
```

![Promote subroot on DC02](/homelab-setup-day-3/promote-subroot-dc02.png)

## Further configuration on RSAT

Since both DC01 and DC02 are running on Windows Server Core (no GUI possible), so you may need to configure AD CS services on Windows client

First thing to consider is enable auditing, to track configuration changes, certification requests, and so on.

![Enable Auditing](/homelab-setup-day-3/enable-auditing.png)
