Get-WmiObject Win32_UserAccount -Filter "Name='vagrant'" | % { $_.PasswordExpires = $false; $_.Put() } | Out-Null

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HiberFileSizePercent" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0 -Force

if ((Get-WmiObject -Class Win32_OperatingSystem).ProductType -ne 1) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 1 -Force
}

[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge", "HideFirstRunExperience", 1)
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoRebootWithLoggedOnUsers", 1)
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU", "IncludeRecommendedUpdates", 0)
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions", 2)
