while ($true) {
    try {
        Write-Host "[INFO] Checking if domain is ready"
        Get-ADDomain | Out-Null
        break
    } catch {
        Write-Host "[INFO] Sleeping for 60s"
        Start-Sleep -Seconds 60
    }
}

Write-Host "[INFO] Domain is ready"