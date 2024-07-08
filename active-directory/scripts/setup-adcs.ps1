param
(
    [string]$DomainName = "contoso.com",
    [string]$Username   = "Administrator",
    [string]$Password   = "vagrant"
)

$p = ConvertTo-SecureString $Password -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential("$DomainName\$Username", $p)
$CACommonName = "$($DomainName.Split(".")[0].ToUpper())-CA"

try {
    Install-WindowsFeature -Name AD-Certificate -IncludeAllSubFeature -IncludeManagementTools | Out-Null
    Install-WindowsFeature -Name ADCS-Cert-Authority | Out-Null
    Install-WindowsFeature -Name ADCS-Web-Enrollment | Out-Null
    Install-WindowsFeature -Name RSAT | Out-Null

    Write-Host "[INFO] Installed ADCS Windows Features"
} catch {
    Write-Host "[ERR] Failed to install ADCS Windows Features"
}

try {
    Install-AdcsCertificationAuthority `
        -Credential $c `
        -CAType EnterpriseRootCA `
        -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
        -KeyLength 2048 `
        -HashAlgorithmName SHA256 `
        -ValidityPeriod Years `
        -ValidityPeriodUnits 5 `
        -CACommonName $CACommonName `
        -Force | Out-Null

    Write-Host "[INFO] Installed ADCS Certification Authority"
} catch {
    Write-Host "[ERR] Failed to install ADCS Certification Authority"
}

try {
    Install-AdcsWebEnrollment -Force | Out-Null

    Write-Host "[INFO] Installed ADCS Web Enrollment"
} catch {
    Write-Host "[ERR] Failed to install ADCS Web Enrollment"
}