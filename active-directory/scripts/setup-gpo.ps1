param (
    [string]$DomainName = "contoso.com",
    [string]$Username   = "Administrator",
    [string]$Password   = "vagrant"
)

@"
`$DomainName = "$DomainName"
`$DomainNameDN = "DC=`$(`$DomainName.Split(".")[0]),DC=`$(`$DomainName.Split(".")[1])"
`$DomainUsers = Get-ADGroup "Domain Users"
try {
    `$GPO1 = New-GPO -Name "TestGPO1"
    `$GPO2 = New-GPO -Name "TestGPO2"
    Set-GPPermission -Name `$GPO1.DisplayName -PermissionLevel GpoEditDeleteModifySecurity -TargetName `$DomainUsers.Name -TargetType Group | Out-Null
    Set-GPPermission -Name `$GPO2.DisplayName -PermissionLevel GpoEditDeleteModifySecurity -TargetName `$DomainUsers.Name -TargetType Group | Out-Null

    Write-Host "[INFO] Created insecure GPOs `$(`$GPO1.DisplayName), `$(`$GPO2.DisplayName) with GpoEditDeleteModifySecurity"
} catch {
    Write-Host "[ERR] Failed to create insecure GPOs `$(`$GPO1.DisplayName), `$(`$GPO2.DisplayName) with GpoEditDeleteModifySecurity"
}

try {
    New-GPLink -Name `$GPO1.DisplayName -Target "`$DomainNameDN" -LinkEnabled Yes | Out-Null
    New-GPLink -Name `$GPO2.DisplayName -Target "`$DomainNameDN" -LinkEnabled Yes | Out-Null
    
    Write-Host "[INFO] Created GP links for `$(`$GPO1.DisplayName), `$(`$GPO2.DisplayName) on `$DomainNameDN"
} catch {
    Write-Host "[ERR] Failed to create GP links for `$(`$GPO1.DisplayName), `$(`$GPO2.DisplayName) on `$DomainNameDN"
}
"@ | Out-File C:\setup\setup-vulnerable-gpo.ps1

if (Test-Path C:\setup\PsExec64.exe -PathType Leaf) {
    & C:\setup\PsExec64.exe -accepteula -u "$DomainName\$Username" -p "$Password" powershell.exe -ExecutionPolicy Bypass -File C:\setup\setup-vulnerable-gpo.ps1
    Write-Host "[INFO] Executed C:\setup\setup-vulnerable-gpo.ps1 via PsExec64.exe, as $DomainName\$Username"
} else {
    Write-Host "[ERR] C:\setup\PsExec64.exe not found, will not run C:\setup\setup-vulnerable-gpo.ps1"
}
