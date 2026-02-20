$domainName = "workshop.neko" # You can change your domain

# Check if the ADDS roles are installed
$isADDSInstalled = $false
$addsRoleStatus = Get-WindowsFeature -Name "AD-Domain-Services"
if ($addsRoleStatus.InstallState -eq "Installed") {
    Write-Host "AD DS Services are installed!"
    $isADDSInstalled = $true
} else {
    Write-Host "AD DS Services are not installed!" -ForegroundColor Red
}

# Check if the DNS roles are installed
$isDNSInstalled = $false
$dnsRoleStatus = Get-WindowsFeature -Name "DNS"
if ($dnsRoleStatus.InstallState -eq "Installed") {
    Write-Host "DNS is installed!"
    $isDNSInstalled = $true
} else {
    Write-Host "DNS is not installed!" -ForegroundColor Red
}

if (-not ($isADDSInstalled) -or -not($isDNSInstalled)) {
    Write-Host "Unable to promote to domain controller. Please review in Install-ADRoles.ps1 for configuration" -ForegroundColor Red
    exit 1
}

# Promote to AD DS FSMO
Write-Host "Promoting to AD DS FSMO"
Install-ADDSForest -DomainName "$domainName" -InstallDNS