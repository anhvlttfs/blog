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
