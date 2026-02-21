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