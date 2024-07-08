# packer-templates

## NOTE:
- packer opens random ports for preseed files, ensure firewall is disabled

## useful commands
- list virtualbox os types: `VBoxManage list ostypes`
- remove virtualbox old uuids: `vboxmanage list hdds; vboxmanage closemedium disk <uuid> --delete`

## templates

## base-box-kali-top10-xfce.json

| Configuration         | Value |
| --------------------- | ----- |
| Builder types         | `virtualbox-iso` |
| ISO                   | `iso/kali-linux-2024.2-installer-everything-amd64.iso` |
| ISO sha256 checksum   | `c49ede57d4ba42f237f2b2582169d9abf42580dd235717395a3e6674454623e9` |
| VM Name               | `base-box-kali-top10-xfce` |
| Output directory      | `box` |
| Default resources     | 4 CPUs, 4.0 GB, 200.0 GB |
| Provisioners          | `files/scripts/linux/sysprep.sh` |
| Files                 | N/A |
| Default credentials   | `root`:`root`, `kali`:`kali` |

## base-box-ubuntu-20.04-server.json

| Configuration         | Value |
| --------------------- | ----- |
| Builder types         | `virtualbox-iso` |
| ISO                   | `iso/ubuntu-20.04-live-server-amd64.iso` |
| ISO sha256 checksum   | `caf3fd69c77c439f162e2ba6040e9c320c4ff0d69aad1340a514319a9264df9f` |
| VM Name               | `base-box-ubuntu-20.04-server` |
| Output directory      | `box` |
| Default resources     | 2 CPUs, 2.0 GB, 100.0 GB |
| Provisioners          | `files/scripts/linux/sysprep.sh` |
| Files                 | N/A |
| Default credentials   | `root`:`root`, `ubuntu`:`ubuntu` |

## base-box-win10-22h2-pro.json

| Configuration         | Value |
| --------------------- | ----- |
| Builder types         | `virtualbox-iso` |
| ISO                   | `iso/Win10_22H2_English_x64.iso` |
| ISO sha256 checksum   | `f41ba37aa02dcb552dc61cef5c644e55b5d35a8ebdfac346e70f80321343b506` |
| VM Name               | `base-box-win10-22h2` |
| Output directory      | `box` |
| Default resources     | 2 CPUs, 4.0 GB, 100.0 GB |
| Provisioners          | `files/scripts/windows/vagrant-init.ps1`, `files/scripts/windows/setup-vboxtools.ps1`, `files/scripts/windows/cleanup.ps1` |
| Files                 | `files/scripts/windows/vagrant-sysprep-shutdown.bat` -> `C:\vagrant-sysprep-shutdown.bat` |
| Default credentials   | `N/A, VM is sysprepped` |

## base-box-winserver2016.json

| Configuration         | Value |
| --------------------- | ----- |
| Builder types         | `virtualbox-iso` |
| ISO                   | `iso/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.iso` |
| ISO sha256 checksum   | `1ce702a578a3cb1ac3d14873980838590f06d5b7101c5daaccbac9d73f1fb50f` |
| VM Name               | `base-box-winserver2016` |
| Output directory      | `box` |
| Default resources     | 2 CPUs, 4.0 GB, 100.0 GB |
| Provisioners          | `files/scripts/windows/vagrant-init.ps1`, `files/scripts/windows/setup-vboxtools.ps1`, `files/scripts/windows/cleanup.ps1` |
| Files                 | `files/scripts/windows/vagrant-sysprep-shutdown.bat` -> `C:\vagrant-sysprep-shutdown.bat` |
| Default credentials   | `N/A, VM is sysprepped` |

## base-box-winserver2019.json

| Configuration         | Value |
| --------------------- | ----- |
| Builder types         | `virtualbox-iso` |
| ISO                   | `iso/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso` |
| ISO sha256 checksum   | `549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1` |
| VM Name               | `base-box-winserver2019` |
| Output directory      | `box` |
| Default resources     | 2 CPUs, 4.0 GB, 100.0 GB |
| Provisioners          | `files/scripts/windows/vagrant-init.ps1`, `files/scripts/windows/setup-vboxtools.ps1`, `files/scripts/windows/cleanup.ps1` |
| Files                 | `files/scripts/windows/vagrant-sysprep-shutdown.bat` -> `C:\vagrant-sysprep-shutdown.bat` |
| Default credentials   | `N/A, VM is sysprepped` |
