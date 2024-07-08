$DomainName          = "contoso.com"
$DomainNameDN        = "DC=$($DomainName.Split(".")[0]),DC=$($DomainName.Split(".")[1])"
$UserPassword        = "User1234!"
$ServiceUserPassword = "Svc1234!"
$DomainOU            = $DomainName.Split(".")[0]
$UsersOU             = "Users"
$ComputersOU         = "Computers"
$ServiceAccountsOU   = "Service Accounts"

# pick a random user or computer object from the domain
Function Get-RandomObject {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$User,
        [Parameter()]
        [switch]$Computer
    )

    if ($User) {
        return (Get-ADUser -Filter 'Description -notlike "*"' -SearchBase "OU=$UsersOU,OU=$DomainOU,$DomainNameDN" -Properties Description | Get-Random)
    }

    if ($Computer) {
        return (Get-ADComputer -Filter 'Description -notlike "*"' -SearchBase "OU=$ComputersOU,OU=$DomainOU,$DomainNameDN" -Properties Description | Get-Random)
    }
}

# https://github.com/davidprowe/BadBlood/blob/master/AD_OU_SetACL/Full%20Control%20Permissions.ps1
Function SetAcl($for, $to, $right, $inheritance)
{
    Set-Location AD:
    $forSID = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser $for).SID
    $objOU = ($to).DistinguishedName
    $objAcl = get-acl $objOU
    # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $adRight =  [System.DirectoryServices.ActiveDirectoryRights] $right # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $type =  [System.Security.AccessControl.AccessControlType] "Allow" # https://docs.microsoft.com/fr-fr/dotnet/api/system.security.accesscontrol.accesscontroltype?view=dotnet-plat-ext-5.0
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $inheritance # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectorysecurityinheritance?view=dotnet-plat-ext-5.0
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $forSID,$adRight,$type,$inheritanceType
    $objAcl.AddAccessRule($ace)
    Set-Acl -AclObject $objAcl -path $objOU
    Set-ADObject $for -Description "$right on $($to | Select-Object -ExpandProperty Name)"
    Set-ADObject $to -Description "$($for | Select-Object -ExpandProperty Name) has $right on this object"
}

# https://jorgequestforknowledge.wordpress.com/2014/08/20/powershell-and-dacls-in-ad-adding-ace-for-some-extended-right-on-some-object/
Function SetAclExtended($for, $to, $right, $extendedRightGUID, $inheritance)
{
    Set-Location AD:
    $forSID = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser $for).SID
    $objOU = ($to).DistinguishedName
    $objAcl = get-acl $objOU
    # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $adRight =  [System.DirectoryServices.ActiveDirectoryRights] $right # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $type =  [System.Security.AccessControl.AccessControlType] "Allow" # https://docs.microsoft.com/fr-fr/dotnet/api/system.security.accesscontrol.accesscontroltype?view=dotnet-plat-ext-5.0
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $inheritance # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectorysecurityinheritance?view=dotnet-plat-ext-5.0
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $forSID,$adRight,$type,$extendedRightGUID,$inheritanceType
    $objAcl.AddAccessRule($ace)
    Set-Acl -AclObject $objAcl -path $objOU
    Set-ADObject $for -Description "$right, $extendedRightGUID on $($to | Select-Object -ExpandProperty Name)"
    Set-ADObject $to -Description "$($for | Select-Object -ExpandProperty Name) has $right, $extendedRightGUID on this object"
}

# create domain organizational unit
If (-Not (Get-ADOrganizationalUnit -SearchBase "$DomainNameDN" -Filter "Name -like '$DomainOU'")) {
    New-ADOrganizationalUnit -Name "$DomainOU" -Path "$DomainNameDN"
}

# create users organizational unit
if (-Not (Get-ADOrganizationalUnit -SearchBase "OU=$DomainOU,$DomainNameDN" -Filter "Name -like '$UsersOU'")) {
    New-ADOrganizationalUnit -Name "$UsersOU" -Path "OU=$DomainOU,$DomainNameDN"
}

# create computers organizational unit
if (-Not (Get-ADOrganizationalUnit -SearchBase "OU=$DomainOU,$DomainNameDN" -Filter "Name -like '$ComputersOU'")) {
    New-ADOrganizationalUnit -Name "$ComputersOU" -Path "OU=$DomainOU,$DomainNameDN"
}

# create service accounts organizational unit
if (-Not (Get-ADOrganizationalUnit -SearchBase "OU=$DomainOU,$DomainNameDN" -Filter "Name -like '$ServiceAccountsOU'")) {
    New-ADOrganizationalUnit -Name "$ServiceAccountsOU" -Path "OU=$DomainOU,$DomainNameDN"
}


#Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

# create dummy user objects
$users = @("michael","christopher","jessica","matthew","ashley","jennifer","joshua","amanda","daniel","david","james","robert","john","joseph","andrew","ryan","brandon","jason","justin","sarah","william","jonathan","stephanie","brian","nicole","nicholas","anthony","heather","eric","elizabeth","adam","megan","melissa","kevin","steven","thomas","timothy","christina","kyle","rachel","laura","lauren","amber","brittany","danielle","richard","kimberly","jeffrey","amy","crystal","michelle","tiffany","jeremy","benjamin","mark","emily","aaron","charles","rebecca","jacob","stephen","patrick","sean","erin","zachary","jamie","kelly","samantha","nathan","sara","dustin","paul","angela","tyler","scott","katherine","andrea","gregory","erica","mary","travis","lisa","kenneth","bryan","lindsey","kristen","jose","alexander","jesse","katie","lindsay","shannon","vanessa","courtney","christine","alicia","cody","allison","bradley","samuel")

$created_users = @()
ForEach ($user in $users) {
    try {
        New-ADUser -Name "$user" `
            -SamAccountName "$user" `
            -EmailAddress "$user@$($DomainName.ToLower())" `
            -Path "OU=$UsersOU,OU=$DomainOU,$DomainNameDN" `
            -AccountPassword (ConvertTo-SecureString -AsPlainText -Force $UserPassword) `
            -Enabled $true
        $created_users += $user
    } catch {
        Write-Host "[ERR] Failed to create user $user"
    }
}

# add two Domain Admins
Get-RandomObject -User | % { Add-ADGroupMember -Identity "Domain Admins" -Members $_; Set-ADUser -Identity $_ -Description "domain admin" }
Get-RandomObject -User | % { Add-ADGroupMember -Identity "Domain Admins" -Members $_; Set-ADUser -Identity $_ -Description "domain admin" }

Write-Host "[INFO] Created users: $($created_users -Join ', ')"

# create dummy computer objects
$created_computers = @()
1..20 | % {
    $servers = @("srv", "sql", "smb")
    ForEach ($server in $servers) {
        try {
            New-ADComputer -SamAccountName "$server$_" -Name "$server$_" -DNSHostName "$server$_.$DomainName" -Path "OU=$ComputersOU,OU=$DomainOU,$DomainNameDN"
            $created_computers += $server
        } catch {
            Write-Host "[ERR] Failed to create server $server$_"
        }
    }
}

Write-Host "[INFO] Created computers: $($created_computers -Join ', ')"

# create dummy service accounts and spns
$svc_users = @{
    "svc_mssql01"           = @{"type" = "spn"; "value" = "MSSQLSVC"}
    "svc_mssql02"           = @{"type" = "spn"; "value" = "MSSQLSVC"}
    "svc_cifs01"            = @{"type" = "spn"; "value" = "CIFS"}
    "svc_cifs02"            = @{"type" = "spn"; "value" = "CIFS"}
    "svc_iis01"             = @{"type" = "spn"; "value" = "HTTP"}
    "svc_iis02"             = @{"type" = "spn"; "value" = "HTTP"}
    "svc_backup01"          = @{"type" = "group"; "value" = "Backup Operators"}
    "svc_backup02"          = @{"type" = "group"; "value" = "Backup Operators"}
    "svc_dns01"             = @{"type" = "group"; "value" = "DnsAdmins"}
    "svc_dns02"             = @{"type" = "group"; "value" = "DnsAdmins"}
    "svc_srvoperator01"     = @{"type" = "group"; "value" = "Server Operators"}
    "svc_srvoperator02"     = @{"type" = "group"; "value" = "Server Operators"}
    "svc_evtvwr01"          = @{"type" = "group"; "value" = "Event Log Readers"}
    "svc_evtvwr02"          = @{"type" = "group"; "value" = "Event Log Readers"}
    "svc_acctoperator01"    = @{"type" = "group"; "value" = "Account Operators"}
    "svc_acctoperator02"    = @{"type" = "group"; "value" = "Account Operators"}
    "svc_printoperator01"   = @{"type" = "group"; "value" = "Print Operators"}
    "svc_printoperator02"   = @{"type" = "group"; "value" = "Print Operators"}
    "svc_mgmtuser01"        = @{"type" = "group"; "value" = "Remote Management Users"}
    "svc_mgmtuser02"        = @{"type" = "group"; "value" = "Remote Management Users"}
}

$created_svc_users = @()
ForEach ($user in $svc_users.keys) {
    $type   = $svc_users[$user]["type"]
    $value  = $svc_users[$user]["value"]

    Switch ("$type") {
        "spn" {
            try {
                $comp = (Get-RandomObject -Computer | Select-Object -ExpandProperty DNSHostName)
                $u = New-ADUser -Name "$user" `
                    -SamAccountName "$user" `
                    -AccountPassword (ConvertTo-SecureString -AsPlainText -Force $ServiceUserPassword) `
                    -Path "OU=$ServiceAccountsOU,OU=$DomainOU,$DomainNameDN" `
                    -Enabled $true `
                    -PassThru
                Set-ADUser -Identity "$u" -ServicePrincipalNames @{Add="$value/$comp"}
                Set-ADObject $u -Description "SPN on $value/$comp"

                $created_svc_users += "$user ($value/$comp)"
            } catch {
                Write-Host "[ERR] Failed to create $value/$comp for $user"
            }
        }
        "group" {
            try {
                $u = New-ADUser -Name "$user" `
                    -SamAccountName "$user" `
                    -AccountPassword (ConvertTo-SecureString -AsPlainText -Force $UserPassword) `
                    -Path "OU=$ServiceAccountsOU,OU=$DomainOU,$DomainNameDN" `
                    -Enabled $true `
                    -PassThru
                Add-ADGroupMember -Identity "$value" -Members $u
                Set-ADObject $u -Description "member of $value"
                
                $created_svc_users += "$user ($value)"
            } catch {
                Write-Host "[ERR] Failed to add $user to $value"
            }
        }
    }
}

Write-Host "[INFO] Created svc users: $($created_svc_users -Join ', ')"

# NOTE: conflicts with ADCS setup
# create a service account with cifs spn on domain controller
#$dc = (Get-ADDomainController | Select-Object -ExpandProperty HostName)
#$u = New-ADUser -Name "svc_cifs03" `
#    -SamAccountName "svc_cifs03" `
#    -Path "OU=$ServiceAccountsOU,OU=$DomainOU,$DomainNameDN" `
#    -AccountPassword (ConvertTo-SecureString -AsPlainText -Force $ServiceUserPassword) `
#    -Enabled $true `
#    -PassThru
#Set-ADUser -Identity "$u" -ServicePrincipalNames @{Add="CIFS/$dc"}
#Set-ADObject $u -Description "SPN on CIFS/$dc"

try {
    # create a service account for iis
    $dc = (Get-ADDomainController | Select-Object -ExpandProperty HostName)
    $u = New-ADUser -Name "svc_iis03" `
        -SamAccountName "svc_iis03" `
        -Path "OU=$ServiceAccountsOU,OU=$DomainOU,$DomainNameDN" `
        -AccountPassword (ConvertTo-SecureString -AsPlainText -Force $ServiceUserPassword) `
        -Enabled $true `
        -PassThru
    Set-ADUser -Identity "$u" -ServicePrincipalNames @{Add="HTTP/web01"}
    Set-ADObject $u -Description "SPN on HTTP/web01"

    # genericall-on-user
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericall-on-user
    SetAcl (Get-RandomObject -User) (Get-RandomObject -User) "GenericAll" "None"

    # genericall-on-group
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericall-on-group
    SetAcl (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "GenericAll" "None"

    # genericall-genericwrite-write-on-computer
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericall-genericwrite-write-on-computer
    SetAcl (Get-RandomObject -User) (Get-RandomObject -Computer) "GenericAll" "None"

    # writeproperty-on-group
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#writeproperty-on-group
    SetAcl (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "WriteProperty" "All"

    # self-self-membership-on-group
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#self-self-membership-on-group
    SetAclExtended (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "Self" "bf9679c0-0de6-11d0-a285-00aa003049e2" "None"

    # writeproperty-self-membership
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#writeproperty-self-membership
    SetAclExtended (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "WriteProperty" "bf9679c0-0de6-11d0-a285-00aa003049e2" "All"

    # forcechangepassword
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#forcechangepassword
    # https://docs.microsoft.com/fr-fr/windows/win32/adschema/r-user-change-password
    SetAclExtended (Get-RandomObject -User) (Get-RandomObject -User) "ExtendedRight" "00299570-246d-11d0-a768-00aa006e0529" "None"

    # write owner on group
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#writeowner-on-group
    SetAcl (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "WriteOwner" "None"

    # genericwrite-on-user
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericwrite-on-user
    SetAcl (Get-RandomObject -User) (Get-RandomObject -User) "GenericWrite" "None"

    # writedacl-writeowner
    # https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#writedacl-writeowner
    SetAcl (Get-RandomObject -User) (Get-ADGroup "Domain Admins") "WriteDacl" "None"

    # asreproast
    $asreproast_user = Get-RandomObject -User
    Set-ADAccountControl -Identity $asreproast_user -DoesNotRequirePreAuth $True
    Set-ADObject $asreproast_user -Description "DoesNotRequirePreAuth"

    # kerberoast
    $kerberoast_user = Get-RandomObject -User
    $kerberoast_spn = Get-RandomObject -Computer
    Set-ADUser -Identity "$kerberoast_user" -ServicePrincipalNames @{Add="HTTP/$($kerberoast_spn)"}
    Set-ADObject $kerberoast_user -Description "$($kerberoast_user | Select-Object -ExpandProperty Name) is kerberoastable on http/$($kerberoast_spn | Select-Object -ExpandProperty Name):80"

    # TrustedForDelegation
    $unconstrained_delegation_comp = Get-RandomObject -Computer
    $unconstrained_delegation_comp | Set-ADAccountControl -TrustedForDelegation $true
    Set-ADObject $unconstrained_delegation_comp -Description "TrustedForDelegation"

    # msDS-AllowedToDelegateTo
    $constrained_delegation_comp1 = Get-RandomObject -Computer 
    $constrained_delegation_comp2 = Get-RandomObject -Computer
    Set-ADObject -Identity $constrained_delegation_comp1 -Add @{'msDS-AllowedToDelegateTo'=@("HOST/$($constrained_delegation_comp2)/example")}
    Set-ADAccountControl -Identity $constrained_delegation_comp1 -TrustedForDelegation $false -TrustedToAuthForDelegation $true
    Set-ADObject $constrained_delegation_comp1 -Description "msDS-AllowedToDelegateTo to $($constrained_delegation_comp2 | Select-Object -ExpandProperty Name)"

    # anonymous LDAP
    $anonymousId = New-Object System.Security.Principal.NTAccount "NT AUTHORITY\ANONYMOUS LOGON"
    $secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
    $Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $anonymousId,"ReadProperty, GenericExecute","Allow",$secInheritanceAll
    $Acl = Get-Acl -Path "AD:\$(Get-ADDomainController | Select-Object -ExpandProperty ComputerObjectDN)"
    $Acl.AddAccessRule($Ace)
    Set-Acl -Path "AD:\$(Get-ADDomainController | Select-Object -ExpandProperty ComputerObjectDN)" -AclObject $Acl

    Write-Host "[INFO] Created vulnerable ACLS, vulnerable delegation configurations, vulnerable kerberos configuration"
} catch {
    Write-Host "[ERR] Failed to create vulnerable ACLS, vulnerable delegation configurations, vulnerable kerberos configuration"
}

@"
Domain content
--------------
"@ | Out-File C:\README.txt

Get-AdObject `
    -SearchBase "OU=$DomainOU,$DomainNameDN" `
    -Filter {ObjectClass -ne "OrganizationalUnit"} `
    -Properties Name, ObjectClass, Description `
        | Select-Object Name, ObjectClass, Description `
        | Format-Table -AutoSize `
        | Out-File -Append C:\README.txt
