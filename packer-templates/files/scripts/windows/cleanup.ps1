$ErrorActionPreference = "SilentlyContinue"
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue | Out-Null

try {
    $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
    $System.AutomaticManagedPagefile = $False
    $System.Put() | Out-Null
    $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
    $CurrentPageFile.InitialSize = 512
    $CurrentPageFile.MaximumSize = 512
    $CurrentPageFile.Put() | Out-Null

    Write-Host "[INFO] Changed pagefile size"
} catch {
    Write-Host "[ERR] Error occured while attempting to modify pagefile size"
    Write-Host "$($_.Exception.Message)"
}

try {
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase /Quiet
    Write-Host "[INFO] Executed dism to cleanup image and reset"
} catch {
    Write-Host "[ERR] Error occured while running dism to cleanup image and reset"
    Write-Host "$($_.Exception.Message)"
}

try {
    Remove-Item -Path "C:\Recovery" -Recurse -Force
    Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force | Remove-Item -Recurse -Force | Out-Null
    Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force | Remove-Item -Recurse -Force | Out-Null
    Get-ChildItem "C:\Users\*\AppData\Local\Temp\*"   -Recurse -Force | Remove-Item -Recurse -Force | Out-Null
    Get-ChildItem "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force | Remove-Item -Recurse -Force | Out-Null
    Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter *uninstall*.lnk | % { Remove-Item -Force $_.FullName | Out-Null }

    @(
        "$env:localappdata\Nuget",
        "$env:localappdata\temp\*",
        "$env:windir\logs",
        "$env:windir\panther",
        "$env:windir\temp\*",
        "$env:windir\winsxs\manifestcache"
    ) | ForEach-Object {
        if ((Test-Path $_) -And ($_ -NotLike "*.ps1")) {
            try {
                Takeown /d Y /R /f $_ 2>&1 | Out-Null
                Icacls $_ /GRANT:r administrators:F /T /c /q 2>&1 | Out-Null
                Remove-Item $_ -Recurse -Force | Out-Null
            }
            catch { $global:error.RemoveAt(0) }
        }
    }

    Write-Host "[INFO] Removed temporary and build files"
} catch {
    Write-Host "[ERR] Error occured while attempting to remove temporary and build files"
    Write-Host "$($_.Exception.Message)"
}

try {
    & defrag.exe C: /h *> $null
    Write-Host "[INFO] Executed defrag.exe"
}
catch {
    Write-Host "[ERR] Error occured while running defrag.exe"
    Write-Host "$($_.Exception.Message)"
}

try {
    & cleanmgr.exe /verylowdisk *> $null
    Write-Host "[INFO] Executed cleanmgr.exe"
}
catch {
    Write-Host "[ERR] Error occured while running cleanmgr.exe"
    Write-Host "$($_.Exception.Message)"
}

try {
    $FilePath = "C:\zero.tmp"
    $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
    $ArraySize = 64kb
    $SpaceToLeave = $Volume.Size * 0.05
    $FileSize = $Volume.FreeSpace - $SpaceToLeave
    $ZeroArray = New-Object byte[]($ArraySize)

    $Stream = [IO.File]::OpenWrite($FilePath)
    try {
        $CurFileSize = 0
        while ($CurFileSize -lt $FileSize) {
            $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
            $CurFileSize += $ZeroArray.Length
        }
    }
    finally {
        if ($Stream) {
            $Stream.Close()
        }
    }

    Remove-Item $FilePath

    Write-Host "[INFO] Zeroed out empty space"
} catch {
    Write-Host "[ERR] Error occured while attempting to zero out empty space"
    Write-Host "$($_.Exception.Message)"
}

try {
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    powercfg /change disk-timeout-ac 0
    powercfg /change disk-timeout-dc 0
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0

    Write-Host "[INFO] Disabled screen timeout, disk timeout, standby, hibernate"
} catch {
    Write-Host "[ERR] Error occured while attempting to modify screen timeout, disk timeout, standby, hibernate"
    Write-Host "$($_.Exception.Message)"
}

try {
    Clear-EventLog -LogName (Get-EventLog -List).log
    Clear-EventLog -LogName (Get-EventLog -List).log
    Clear-EventLog -LogName (Get-EventLog -List).log

    Write-Host "[INFO] Cleared out event logs"
} catch {
    Write-Host "[ERR] Error occured while clearing event logs"
    Write-Host "$($_.Exception.Message)"
}
