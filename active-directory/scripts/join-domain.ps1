param
(
    [string]$DomainName = "contoso.com",
    [string]$Username   = "Administrator",
    [string]$Password   = "vagrant"
)

$p = ConvertTo-SecureString $Password -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential($Username, $p)
Add-Computer -DomainName $DomainName -Credential $c