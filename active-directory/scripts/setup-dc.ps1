param
(
    [string]$DomainName          = "contoso.com",
    [string]$FunctionalLevel     = "WinThreshold",
    [string]$SafeModePassword    = "P4ssw0rd1234!"
)

$NetBiosName = $DomainName.Split(".")[0].ToUpper()

Write-Host "[INFO] Disabling password complexity policy"
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item -Force C:\secpol.cfg -Confirm:$false

Write-Host "[INFO] Setting Administrator password"
$computerName = $env:COMPUTERNAME
$adminPassword = "vagrant"
$adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
$adminUser.SetPassword($adminPassword)

Write-Host "[INFO] Installing Ad-Domain-Services Windows feature + subfeatures"
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools | Out-Null

Write-Host "[INFO] Importing ADDSDeployment module"
Import-Module ADDSDeployment | Out-Null

try {
    Write-Host "[INFO] Installing ADDSForest"
    Install-ADDSForest `
        -InstallDns `
        -CreateDnsDelegation:$false `
        -ForestMode $FunctionalLevel `
        -DomainMode $FunctionalLevel `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBiosName `
        -DatabasePath "C:\Windows\NTDS" `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -NoRebootOnCompletion `
        -Force `
        -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText -Force "$SafeModePassword") | Out-Null
    Write-Host "[INFO] Created Active Directory domain for $DomainName"
} catch {
    Write-Host "[ERR] Failed to create Active Directory domain for $DomainName"
}
