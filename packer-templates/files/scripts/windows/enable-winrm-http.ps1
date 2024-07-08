Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
Start-Process -FilePath C:\Windows\System32\cmd.exe -ArgumentList "/c sc.exe config WinRM start= delayed-auto" -Wait -Verbose
Start-Process -FilePath C:\Windows\System32\cmd.exe -ArgumentList "/c sc.exe stop WinRM" -Wait -Verbose
Start-Process -FilePath C:\Windows\System32\cmd.exe -ArgumentList "/c sc.exe start WinRM" -Wait -Verbose

New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
    -Name LocalAccountTokenFilterPolicy `
    -Value 1 `
    -Force | Out-Null

New-NetFirewallRule `
    -DisplayName WINRM-HTTP-In-TCP-VAGRANT `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 5985 | Out-Null

#netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
#netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow remoteip=any
