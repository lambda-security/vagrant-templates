try {
    SqlCmd -E -Q "EXEC master.dbo.sp_addlinkedserver @server = N'mssql01', @srvproduct=N'', @provider=N'SQLOLEDB', @datasrc=N'mssql01'"
    SqlCmd -E -Q "EXEC master.dbo.sp_serveroption @server=N'mssql01', @optname=N'rpc', @optvalue=N'true'"
    SqlCmd -E -Q "EXEC master.dbo.sp_serveroption @server=N'mssql01', @optname=N'rpc out', @optvalue=N'true'"
    SqlCmd -E -Q "EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'mssql01', @locallogin = NULL , @useself = N'True'"
    Write-Host "[INFO] Linked mssql01 to mssql02"
} catch {
    Write-Host "[ERR] Failed to link mssql01 to mssql02"
}
