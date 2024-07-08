param (
    [string]$DomainName = "contoso.com",
    [string]$Username   = "Administrator",
    [string]$Password   = "vagrant"
)

@"
Import-Module ADCSTemplate

Get-ChildItem -Path "C:\setup\templates" -Filter *.json | % {
    `$TemplateName = `$_.BaseName
    if (-not(Get-ADCSTemplate -DisplayName `$TemplateName)) {
        New-ADCSTemplate ``
            -DisplayName `$TemplateName ``
            -JSON (Get-Content "C:\setup\templates\`$_" -Raw) ``
            -Identity "$DomainName\Domain Users" ``
            -Publish
    }
}
"@ | Out-File C:\setup\setup-adcs-esc.ps1

if (Test-Path C:\setup\PsExec64.exe -PathType Leaf) {
    & C:\setup\PsExec64.exe -accepteula -u "$DomainName\$Username" -p "$Password" powershell.exe -ExecutionPolicy Bypass -File C:\setup\setup-adcs-esc.ps1
    Write-Host "[INFO] Executed C:\setup\setup-adcs-esc.ps1 via PsExec64.exe, as $DomainName\$Username"
} else {
    Write-Host "[ERR] C:\setup\PsExec64.exe not found, will not run C:\setup\setup-adcs-esc.ps1"
}

# ESC6
# certutil -setreg policy\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2

# ESC7
# certutil -setsecurityflags -EDITF_ATTRIBUTESUBJECTALTNAME2 CAName
# certutil -store My -user domain\user -addstoreflags enroll
# certutil -store StoreName -user yourdomain\username -addperm -storeflags Flag
