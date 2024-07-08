try {
    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
    ForEach ($drive in $drives) {
        if (Test-Path -Path "${drive}:\VBoxWindowsAdditions.exe" -PathType Leaf) {
            Write-Host "[INFO] Found VirtualBox Guest Additions mounted on ${drive}:\"
            ForEach ($cert in (Get-ChildItem "${drive}:\cert" -Filter "*.cer" | Select-Object -ExpandProperty Name)) {
                Write-Host "[INFO] Adding ${drive}:\cert\$cert to certificate store"
                Start-Process -FilePath "${drive}:\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher ${drive}:\cert\$cert --root ${drive}:\cert\$cert" -Wait -Verbose
            }
            Write-Host "[INFO] Installing ${drive}:\VBoxWindowsAdditions.exe"
            Start-Process -FilePath "${drive}:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait -Verbose
        }
    }
} catch {
    Write-Host "[ERR] Error occured while installing VirtualBox Guest Additions"
    Write-Host "$($_.Exception.Message)"
}
