Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue | Out-Null
Start-Process -FilePath "C:\setup\Sysmon64.exe" -ArgumentList "-accepteula -i C:\setup\sysmonconfig-export.xml" -Wait -Verbose
Start-Process -FilePath "C:\Windows\System32\MsiExec.exe" -ArgumentList "/i C:\setup\googlechromestandaloneenterprise64.msi /qb" -Wait -Verbose
Start-Process -FilePath "C:\setup\npp.exe" -ArgumentList "/S" -Wait -Verbose
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "bginfo", "C:\BgInfo\Bginfo.exe C:\BgInfo\BgInfo.bgi /timer:00 /nolicprompt /silent")
