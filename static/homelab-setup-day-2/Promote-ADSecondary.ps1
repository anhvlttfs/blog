$localDomain = "workshop.neko"
$domainController = "dc01" + ".$localDomain"

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

# Check if the primary domain controller is alive!
$isPrimaryDCCOntacted = $false
$primaryDCContact = Test-NetConnection -ComputerName $domainController
if ($primaryDCContact.PingSucceeded -eq $true) {
    Write-Host "$domainController is on live!"
} else {
    Write-Host "Unable to get status of $domainController. Please verify the network!" -ForegroundColor Red
}

if (-not ($isADDSInstalled) -or -not($isDNSInstalled) -or -not($isPrimaryDCCOntacted)) {
    Write-Host "Unable to promote to domain controller. Please review in Install-ADRoles.ps1 for configuration" -ForegroundColor Red
    exit 1
}

# Promote current server to domain controller

$HashArguments = @{
    Credential = (Get-Credential "Administrator@$localDomain")
    DomainName = "$localDomain"
    InstallDns = $true
}

Install-ADDSDomainController @HashArguments