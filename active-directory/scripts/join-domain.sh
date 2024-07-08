#!/bin/bash

[[ $EUID -ne 0 ]] && printf "%s\n" "run as root" && exit 1

while getopts "d:n:i:p:" arg; do
    case $arg in
        d) domain="${OPTARG}";;
        n) nameserver="${OPTARG}";;
        i) local_ip="${OPTARG}";;
        p) password="${OPTARG}";;
    esac
done

DEBIAN_FRONTEND=noninteractive apt-get update -yqq &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -yqq realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -yqq &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get clean &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get autoclean &>/dev/null

if systemctl is-active systemd-resolved; then
    systemctl disable --now systemd-resolved
    systemctl mask systemd-resolved
fi

rm -rf /etc/resolv.conf
cat > /etc/resolv.conf << EOF
nameserver ${nameserver}
EOF
chattr +i /etc/resolv.conf

if [[ -f /etc/netplan/50-vagrant.yaml ]]; then
    cat > /etc/netplan/50-vagrant.yaml << EOF
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - ${local_ip}/24
      nameservers:
        addresses: [${nameserver}]
EOF
    netplan apply
else
    printf "%s\n" "[ERR] Missing /etc/netplan/50-vagrant.yaml to setup"
fi

sleep 5

if realm discover $domain; then
    echo $password | realm join $domain
    printf "%s\n" "[INFO] Joined ${domain}"
else
    printf "%s\n" "[ERR] Failed to discover ${domain}"
fi

cat > /usr/share/pam-configs/mkhomedir << EOF
Name: Create home directory on login
Default: yes
Priority: 900
Session-Type: Additional
Session:
        optional                        pam_mkhomedir.so
EOF
DEBIAN_FRONTEND=noninteractive pam-auth-update --enable mkhomedir
