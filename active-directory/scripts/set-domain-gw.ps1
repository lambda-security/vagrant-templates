param
(
    [string]$DomainControllerIPAddress = "192.168.56.50",
    [string]$HostIPAddress             = "192.168.56.55"
)

try {
    Get-NetIPAddress | ? { $_.IPAddress -like "192.168.56.*"} | % {
        Remove-NetIPAddress -InterfaceAlias $_.InterfaceAlias -Confirm:$false | Out-Null
        Remove-NetRoute -InterfaceAlias $_.InterfaceAlias -Confirm:$false | Out-Null

        New-NetIPAddress `
            -InterfaceAlias $_.InterfaceAlias `
            -IPAddress "$HostIPAddress" `
            -DefaultGateway "$DomainControllerIPAddress" `
            -PrefixLength 24 | Out-Null

        Set-DnsClientServerAddress `
            -InterfaceAlias $_.InterfaceAlias `
            -ServerAddress "$DomainControllerIPAddress" | Out-Null

        # TODO: fix this
        #Set-DnsClient -InterfaceAlias `
        #    -InterfaceAlias $_.InterfaceAlias `
        #    -ConnectionSpecificSuffix "contoso.com"

        Write-Host "[INFO] Set $($_.InterfaceAlias) IP address to $HostIPAddress and Default Gateway to $DomainControllerIPAddress"
        }
    
} catch {
    Write-Host "[ERR] Failed to set interface IP address and Default Gateway"
}
