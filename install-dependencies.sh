#!/bin/bash

[[ $EUID -ne 0 ]] && printf "%s\n" "run as root" && exit 1

if ! command -v curl &>/dev/null; then
    printf "%s\n" "[INFO] curl not found"
    exit 1
fi

if ! command -v gpg &>/dev/null; then
    printf "%s\n" "[INFO] gpg not found"
    exit 1
fi

if ! command -v dpkg &>/dev/null; then
    printf "%s\n" "[INFO] dpkg not found, is this a Debian/Ubuntu environment?"
    exit 1
fi

curl -sSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
printf "%s" "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y vagrant packer

hash -r

if ! command -v vagrant &>/dev/null; then
    printf "%s\n" "[INFO] vagrant not found, probably failed to install" 
    exit 1
fi

. /etc/os-release
LATEST_STABLE=$(curl -sSL https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)
URL=$(curl -sSL "https://download.virtualbox.org/virtualbox/${LATEST_STABLE}")

UBUNTU_DEB=$(printf "%s" "$URL" | grep -i "${UBUNTU_CODENAME}" | head -1 | grep -Eoi "\".*_amd64.deb\"" | tr -d '"')
curl -sSL "https://download.virtualbox.org/virtualbox/${LATEST_STABLE}/${UBUNTU_DEB}" -o /tmp/virtualbox_amd64.deb
dpkg -i /tmp/virtualbox_amd64.deb
rm -rf /tmp/virtualbox_amd64.deb

EXT_PACK=$(printf "%s" "$URL" | grep -Eoi "\".*.vbox-extpack\"" | head -1 | tr -d '"') 
curl -sSL "https://download.virtualbox.org/virtualbox/${LATEST_STABLE}/${EXT_PACK}" -o "/tmp/${EXT_PACK}"
printf "%s\n" "yes" | sudo VBoxManage extpack install "/tmp/${EXT_PACK}"
rm -rf "/tmp/${EXT_PACK}"

vagrant plugin install vagrant-vbguest
