param
(
    [string]$DomainName   = "contoso.com",
    [string]$SvcUsername  = "svc_mssql01",
    [string]$SvcPassword  = "P4ssw0rd1234!"
)
$NetBiosName = $DomainName.Split(".")[0].ToUpper()

New-Item -Path "C:\setup\media" -ItemType "Directory" -Force | Out-Null

@"
;SQL Server Configuration File
[OPTIONS]
IACCEPTSQLSERVERLICENSETERMS="True"
ACTION="Install"
ENU="True"
QUIET="True"
QUIETSIMPLE="False"
UpdateEnabled="False"
ERRORREPORTING="False"
USEMICROSOFTUPDATE="False"
FEATURES=SQLENGINE,FULLTEXT
UpdateSource="MU"
HELP="False"
INDICATEPROGRESS="False"
X86="False"
INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"
INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"
INSTANCENAME="SQLEXPRESS"
SQMREPORTING="False"
INSTANCEID="SQLEXPRESS"
RSINSTALLMODE="DefaultNativeMode"
INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
AGTSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
AGTSVCSTARTUPTYPE="Automatic"
COMMFABRICPORT="0"
COMMFABRICNETWORKLEVEL="0"
COMMFABRICENCRYPTION="0"
MATRIXCMBRICKCOMMPORT="0"
SQLSVCSTARTUPTYPE="Automatic"
FILESTREAMLEVEL="0"
ENABLERANU="False"
SQLCOLLATION="SQL_Latin1_General_CP1_CI_AS"
SQLSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
SAPWD="$SvcPassword"
SQLSYSADMINACCOUNTS="BUILTIN\Administrators"
ADDCURRENTUSERASSQLADMIN="True"
TCPENABLED="1"
NPENABLED="0"
BROWSERSVCSTARTUPTYPE="Disabled"
RSSVCSTARTUPTYPE="manual"
FTSVCACCOUNT="NT Service\MSSQLFDLauncher"
"@ | Out-File "C:\setup\sql_conf.ini"

try {
    Start-Process -FilePath "C:\setup\SQL2019-SSEI-Expr.exe" -ArgumentList "/configurationfile=C:\setup\sql_conf.ini /IACCEPTSQLSERVERLICENSETERMS /MEDIAPATH=C:\setup\media /QUIET /HIDEPROGRESSBAR" -Wait
    Write-Host "[INFO] Installed SQL Server Express"
} catch {
    Write-Host "[ERR] Failed to install SQL Server Express"
}

try {
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name "TcpPort" -Value "1433" -Force | Out-Null
    Write-Host "[INFO] Set MSSQL port to 1433"
} catch {
    Write-Host "[ERR] Failed to set MSSQL port to 1433"
}

Restart-Service -Name "MSSQL`$SQLEXPRESS"

try {
    $env:Path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn"
    SqlCmd -E -Q "CREATE LOGIN [$NetBiosName\$SvcUsername] FROM WINDOWS" | Out-Null
    SqlCmd -E -Q "SP_ADDSRVROLEMEMBER '$NetBiosName\$SvcUsername', 'SYSADMIN'" | Out-Null

    SqlCmd -E -Q "ALTER LOGIN sa ENABLE" | Out-Null
    SqlCmd -E -Q "ALTER LOGIN sa WITH PASSWORD = '$SvcPassword', CHECK_POLICY=OFF" | Out-Null
    Write-Host "[INFO] Added $NetBiosName\$SvcUsername as MSSQL login and sysadmin"
    Write-Host "[INFO] Enabled SA login"
} catch {
    Write-Host "[ERR] Failed to add $NetBiosName\$SvcUsername as MSSQL login and sysadmin"
    Write-Host "[ERR] Failed to enable SA login"

}

New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow | Out-Null
