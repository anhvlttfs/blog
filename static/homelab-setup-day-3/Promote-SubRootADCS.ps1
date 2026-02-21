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