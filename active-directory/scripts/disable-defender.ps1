if (Test-Path -Path "$env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe" -PathType Leaf) {
    try {
        takeown /f "$env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe" | Out-Null
        icacls "$env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe" /grant administrators:F | Out-Null
        move "$env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe" "$env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" | Out-Null
        Write-Host "[INFO] Disabled defender by renaming $env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe to MsSense.exe.OLD"
    } catch {
        Write-Host "[INFO] Failed to disable defender by renaming $env:ProgramFiles\Windows Defender Advanced Threat Protection\MsSense.exe to MsSense.OLD"
    }
}

if (Test-Path -Path "$env:WinDir\SYSTEM32\SecurityHealthService.exe" -PathType Leaf) {
    try {
        takeown /f "$env:WinDir\SYSTEM32\SecurityHealthService.exe" | Out-Null
        icacls "$env:WinDir\SYSTEM32\SecurityHealthService.exe" /grant administrators:F | Out-Null
        move "$env:WinDir\SYSTEM32\SecurityHealthService.exe" "$env:WinDir\SYSTEM32\SecurityHealthService.exe.OLD" | Out-Null
        Write-Host "[INFO] Disabled defender by renaming $env:WinDir\SYSTEM32\SecurityHealthService.exe to SecurityHealthService.exe.OLD"
    } catch {
        Write-Host "[INFO] Failed to disable defender by renaming $env:WinDir\SYSTEM32\SecurityHealthService.exe to SecurityHealthService.exe.OLD"
    }
}

if (Test-Path -Path "$env:WinDir\SYSTEM32\drivers\WdNisDrv.sys" -PathType Leaf) {
    try {
        takeown /f "$env:WinDir\SYSTEM32\drivers\WdNisDrv.sys" | Out-Null
        icacls "$env:WinDir\SYSTEM32\drivers\WdNisDrv.sys" /grant administrators:F | Out-Null
        move "$env:WinDir\SYSTEM32\drivers\WdNisDrv.sys" "$env:WinDir\SYSTEM32\drivers\WdNisDrv.sys.OLD" | Out-Null
        Write-Host "[INFO] Disabled defender by renaming $env:WinDir\SYSTEM32\drivers\WdNisDrv.sys to WdNisDrv.sys.OLD"
    } catch {
        Write-Host "[INFO] Failed to disable defender by renaming $env:WinDir\SYSTEM32\drivers\WdNisDrv.sys to WdNisDrv.sys.OLD"
    }
}

if (Test-Path -Path "$env:WinDir\SYSTEM32\drivers\WdFilter.sys" -PathType Leaf) {
    try {
        takeown /f "$env:WinDir\SYSTEM32\drivers\WdFilter.sys" | Out-Null
        icacls "$env:WinDir\SYSTEM32\drivers\WdFilter.sys" /grant administrators:F | Out-Null
        move "$env:WinDir\SYSTEM32\drivers\WdFilter.sys" "$env:WinDir\SYSTEM32\drivers\WdFilter.sys.OLD" | Out-Null
        Write-Host "[INFO] Disabled defender by renaming $env:WinDir\SYSTEM32\drivers\WdFilter.sys to WdFilter.sys.OLD"
    } catch {
        Write-Host "[INFO] Failed to disable defender by renaming $env:WinDir\SYSTEM32\drivers\WdFilter.sys to WdFilter.sys.OLD"
    }
}

if (Test-Path -Path "$env:WinDir\SYSTEM32\drivers\WdBoot.sys" -PathType Leaf) {
    try {
        takeown /f "$env:WinDir\SYSTEM32\drivers\WdBoot.sys" | Out-Null
        icacls "$env:WinDir\SYSTEM32\drivers\WdBoot.sys" /grant administrators:F | Out-Null
        move "$env:WinDir\SYSTEM32\drivers\WdBoot.sys" "$env:WinDir\SYSTEM32\drivers\WdBoot.sys.OLD" | Out-Null
        Write-Host "[INFO] Disabled defender by renaming $env:WinDir\SYSTEM32\drivers\WdBoot.sys to WdBoot.sys.OLD"
    } catch {
        Write-Host "[INFO] Failed to disable defender by renaming $env:WinDir\SYSTEM32\drivers\WdBoot.sys to WdBoot.sys.OLD"
    }
}