 param
(
    [string]$DomainName  = "contoso.com",
    [string]$SvcUsername = "svc_iis03",
    [string]$SvcPassword = "Svc1234!"
)

$wwwroot1 = "C:\inetpub\wwwroot"
$wwwroot2 = "C:\inetpub\wwwroot2"

try {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools | Out-Null
    Install-WindowsFeature -Name Web-Asp-Net45 | Out-Null
    New-WebSite -Name "MyASPXSite" -Port 80 -PhysicalPath "C:\inetpub\wwwroot" -ApplicationPool "DefaultAppPool" | Out-Null
    Set-ItemProperty "IIS:\AppPools\DefaultAppPool" -Name processModel -Value @{userName="$SvcUsername";password="$SvcPassword";identityType=3} | Out-Null
    New-NetFirewallRule -DisplayName "HTTP (80)" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow | Out-Null
    Restart-WebAppPool -Name "DefaultAppPool" | Out-Null

    Write-Host "[INFO] Created first IIS WebSite, Firewall rule and AppPool"
} catch {
    Write-Host "[ERR] Failed to create first IIS WebSite, Firewall rule and AppPool"
}

try {
    $svcIIS03Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\$SvcUsername", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl = Get-Acl $wwwroot1
    $acl.SetAccessRule($svcIIS03Rule)
    Set-Acl -Path $wwwroot1 -AclObject $acl | Out-Null

    Write-Host "[INFO] Set ACL for $wwwroot1"
} catch {
    Write-Host "[ERR] Failed to set ACL for $wwwroot1"
}

@"
using System;
using System.IO;
using System.Web.UI;

public partial class UploadPage : Page
{
    protected void UploadFile(object sender, EventArgs e)
    {
        if (fileUpload.PostedFile != null && fileUpload.PostedFile.ContentLength > 0)
        {
            try
            {
                string filename = Path.GetFileName(fileUpload.PostedFile.FileName);
                fileUpload.PostedFile.SaveAs(Server.MapPath(filename));
                lblMessage.Text = "File uploaded successfully!";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }
        else
        {
            lblMessage.Text = "Please select a file to upload.";
        }
    }
}
"@ | Out-File C:\inetpub\wwwroot\upload.aspx.cs

@"
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="upload.aspx.cs" Inherits="UploadPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>File Upload Page</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <input type="file" id="fileUpload" runat="server" />
            <br />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="UploadFile" />
            <br />
            <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
        </div>
    </form>
</body>
</html>
"@ | Out-File C:\inetpub\wwwroot\upload.aspx

@"
<?xml version="1.0"?>
<configuration>
    <system.web>
        <compilation debug="true" targetFramework="4.5"/>
        <httpRuntime targetFramework="4.5"/>
        <customErrors mode="Off"/>
    </system.web>
</configuration>
"@ | Out-File C:\inetpub\wwwroot\Web.config

Restart-WebAppPool -Name "DefaultAppPool" | Out-Null

try {
    Copy-Item "C:\inetpub\wwwroot" -Destination "C:\inetpub\wwwroot2" -Recurse
    New-WebAppPool -Name "DefaultAppPool2" | Out-Null
    New-WebSite -Name "MyASPXSite2" -Port 8080 -PhysicalPath "C:\inetpub\wwwroot2" -ApplicationPool "DefaultAppPool2" | Out-Null
    Set-ItemProperty "IIS:\AppPools\DefaultAppPool2" -Name processModel -Value @{ identityType=2 } | Out-Null
    New-NetFirewallRule -DisplayName "HTTP (8080)" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow | Out-Null

    Write-Host "[INFO] Created second IIS WebSite, Firewall rule and AppPool"
} catch {
    Write-Host "[ERR] Failed to create second IIS WebSite, Firewall rule and AppPool"
}

try {
    $acl = Get-Acl $wwwroot2
    $iisIUSRSGroup = "IIS_IUSRS"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl -Path $wwwroot2 -AclObject $acl  | Out-Null

    Write-Host "[INFO] Set ACL for $wwwroot2"
} catch {
    Write-Host "[ERR] Failed to set ACL for $wwwroot2"
}

Restart-WebAppPool -Name "DefaultAppPool2" | Out-Null