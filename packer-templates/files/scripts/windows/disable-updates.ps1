# https://learn.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-automaticupdatesnotificationlevel
# https://learn.microsoft.com/en-us/archive/blogs/jamesone/managing-windows-update-with-powershell
try {
    $updates = (New-Object -ComObject "Microsoft.Update.AutoUpdate").Settings
    if ($updates.ReadOnly -eq $true) {
        Write-Error "[ERR] Cannot update Windows Update settings due to GPO restrictions"
    } else {
        $updates.NotificationLevel = 1
        $updates.Save()
        $updates.Refresh()
        Write-Output "[INFO] Automatic Windows Updates disabled"
    }
} catch { Write-Output "[ERR] Exception while disabling Automatic Windows Updates" }
