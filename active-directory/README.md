# active-directory

## Configuration

Configuration is set via `config.rb` and by default uses the domain name `CONTOSO.COM` and an ip range of 192.168.56.50 - 192.168.56.60 for virtual machines.

All Windows virtual machines are pre-installed with Sysmon and `files/sysmonconfig-export.xml`, Google Chrome, Notepad++, BgInfo.

Default local credentials, configurable via `config.rb`:

- Windows: `vagrant:vagrant`
- Linux: `root:root`

## Environment

This Vagrantfile sets up a vulnerable Active Directory environment containing:

| Server        | Role                                                                                                                  | OS               |
| ------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------- | 
| dc01          | Primary Domain Controller                                                                                             | Windows Server   |
| mssql01       | mssql database linked with mssql02                                                                                    | Windows Server   |
| mssql02       | mssql database linked in with mssql01                                                                                 | Windows Server   |
| web01         | iis webserver with two sites on port 80 running as a domain service user, and 8080 running as a local network service | Windows Server   |
| adcs01        | Active Directory Certificate Services server configured with esc1, esc2, esc3, esc4 and associated misconfigurations  | Windows Server   |
| srv01         | no-role                                                                                                               | Windows Server   |
| srv02         | no-role                                                                                                               | Ubuntu Server    |
| workstation01 | no-role workstation                                                                                                   | Windows 10       |
| attackbox     | attackbox                                                                                                             | Kali Linux top10 |

Building and running the full environment requires ~100GB of disk space and ~32GB ram.

![active-directory](img/environment.png)

## Usage

```
$ ./active-directory.sh
-u|--up                bring environment up, build the first time
                       specify multiple vms by comma or "all"

-d|--down              bring environment down
                       specify multiple vms by comma or "all"

-s|--snapshot <name>   take environment snapshot with <name>

-r|--restore <name>    restore environment snapshot with <name>

-x|--delete <name>     delete envionment snapshot with <name>

-l|--list              list snapshots

--status               vagrant environment status

-z|--destroy           destroy environment
                       specify multiple vms by comma or "all"

-f|--force             force

-h|--help              print this help message and exit
```

## Building 

```
$ ./active-directory.sh -u all
``` 

## Destroying

```
$ ./active-directory.sh -z all
``` 

## Running

- Bring up entire environment

```
$ ./active-directory.sh -u all
``` 

- Bring up environment selected virtual machines

```
$ ./active-directory.sh -u dc01.domain.com,mssql01.domain.com
``` 

## Snapshotting

- Create snapshot

```
$ ./active-directory.sh -s clean01
``` 

- Restore snapshot

```
$ ./active-directory.sh -r clean01
``` 
