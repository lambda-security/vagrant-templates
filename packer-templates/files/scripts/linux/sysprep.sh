#!/bin/bash
# taken from https://github.com/DanHam/packer-virt-sysprep
set -o errexit
shopt -s nullglob dotglob


function _clean_shell_history() {
    root_hist="$(find /root -type f -name .bash_history)"
    user_hist="$(find /home -type f -name .bash_history | tr -s '\n' ' ')"
    rm -rf ${root_hist} ${user_hist}
    
    set +o errexit
    if [[ -f /.dockerenv ]]; then
        ln -sf /dev/null "/root/.bash_history"

        while read user home; do
            ln -sf /dev/null "${home}/.bash_history" || :
            chown --no-dereference "${user}:${user}" "${home}/.bash_history" || :
        done <<< $(getent passwd | grep -i home | awk -F ':' '($3>=1000) {print $1" "$6}')

    fi
    set -o errexit
}

function _clean_home_dirs() {
    root_files="$(find /root -name .cache -o -name .zshrc -o -name .wget-hsts | tr -s '\n' ' ')"
    user_files="$(find /home -name .cache -o -name go -o -name .zshrc -o -name .wget-hsts | tr -s '\n' ' ')"
    rm -rf ${root_files} ${user_files}
}

function _clean_cloud_init() {
    rm -rf /var/log/installer
    rm -rf /var/lib/cloud/*
    rm -rf /var/log/cloud-init.log
}

function _clean_logs() {
    find /var/log -maxdepth 1 -type f -exec bash -c "echo > {}" \;
}

function _clean_crash_data() {
    crash_data_location=(
        "/var/crash/*"
        "/var/log/dump/*"
    )
    for crash_data in ${crash_data_location[@]}; do rm -rf ${crash_data}; done
}

function _reset_dhcp_state() {
    lease_data_locations=(
        "/var/lib/dhclient/*"
        "/var/lib/dhcp/*"
    )
    for lease_file in ${lease_data_locations[@]}; do rm -rf ${lease_file}; done
}

function _reset_fw_rules() {
    if command -v ufw &>/dev/null; then
        ufw --force reset &>/dev/null
    fi

    if command -v systemctl &>/dev/null; then
        if systemctl is-active -q firewalld.service &>/dev/null; then
            systemctl stop -q firewalld.service
        fi

        if systemctl is-active ufw.service &>/dev/null; then
            systemctl stop -q ufw.service
        fi
    fi

    fw_config_locations=(
        "/etc/sysconfig/iptables"
        "/etc/firewalld/services/*"
        "/etc/firewalld/zones/*"
        "/etc/ufw/user.rules.*"
        "/etc/ufw/before.rules.*"
        "/etc/ufw/after.rules.*"
        "/etc/ufw/user6.rules.*"
        "/etc/ufw/before6.rules.*"
        "/etc/ufw/after6.rules.*"
    )

    for fw_config in ${fw_config_locations[@]}; do rm -rf ${fw_config}; done
}

function _reset_machine_id() {
    sysd_id="/etc/machine-id"
    dbus_id="/var/lib/dbus/machine-id"

    if [[ -e ${sysd_id} ]]; then
        rm -rf ${sysd_id} && touch ${sysd_id}
    fi

    if [[ -e ${dbus_id} && ! -h ${dbus_id} ]]; then
        rm -rf ${dbus_id}
    fi
}

function _clean_mail_spool() {
    mta_list=(
        "exim"
        "postfix"
        "sendmail"
    )

    mail_spool_locations=(
        "/var/spool/mail/*"
        "/var/mail/*"
    )

    for mta in ${mta_list[@]}; do
        if command -v systemctl &>/dev/null ; then
            mta_service="$(systemctl list-units --type service | grep ${mta} | cut -d' ' -f1)"
            if [[ "x${mta_service}" != "x" ]]; then
                if systemctl is-active ${mta_service} &>/dev/null; then
                    systemctl stop ${mta_service}
                fi
            fi
        else
            mta_service="$(find /etc/init.d/ -iname "*${mta}*")"
            if [[ "x${mta_service}" != "x" ]]; then
                if ${mta_service} status | grep running &>/dev/null; then
                    ${mta_service} stop
                fi
            fi
        fi
    done

    for mail_spool in ${mail_spool_locations[@]}; do rm -rf ${mail_spool}; done
}

function _clean_package_manager_cache() {
    cache_locations=(
        "/var/cache/apt/"
        "/var/cache/dnf/"
        "/var/cache/yum/"
        "/var/cache/zypp*"
    )

    for cache_dir in ${cache_locations[@]}; do
        if [[ -d ${cache_dir} ]]; then
            find ${cache_dir} -type f | xargs -I FILE rm -rf FILE
        fi
    done
}

function _clean_package_manager_db() {
    rm -rf /var/lib/rpm/__db.*
    apt_lists=/var/lib/apt/lists
    if [[ -d "${apt_lists}" ]]; then
        find "${apt_lists}" -type f | xargs rm -rf
    fi
}

function _clean_tmp() {
    tmp_locations=(
        "/tmp"
        "/var/tmp"
    )

    mntpnt_orig_tmp="/mnt/orig_tmp"

    shopt -s dotglob

    sum_tmp_space=0
    for tmp in ${tmp_locations[@]}
    do
        if [[ -d ${tmp} ]]; then
            tmp_space="$(du -sm ${tmp} | cut -f1)"
        else
            tmp_space=0
        fi
        sum_tmp_space=$(( ${sum_tmp_space} + ${tmp_space} ))
        if [[ ${sum_tmp_space} -gt 128 ]]; then
            echo "ERROR: Space for copying tmp into memory > 128mb. Exiting"
            exit 1
        fi
    done

    if ! mount -l -t tmpfs | grep /dev/shm &>/dev/null; then
        [[ -d /dev/shm ]] || mkdir /dev/shm && chmod 1777 /dev/shm
        mount -t tmpfs -o defaults,size=128m tmpfs /dev/shm
    fi


    for tmp in ${tmp_locations[@]}; do
        tmp_path="${tmp}"
        on_tmpfs=false

        while [[ ${tmp_path:0:1} = "/" ]] && [[ ${#tmp_path} > 1 ]] && [[ ${on_tmpfs} = false ]]; do
            defifs=${IFS}
            IFS=$'\n'
            for mountpoint in $(mount -l -t tmpfs | cut -d' ' -f3)
            do
                if [[ "${mountpoint}" == "${tmp_path}" ]]; then
                    on_tmpfs=true
                    continue
                fi
            done
            IFS=${defifs}
            tmp_path=${tmp_path%/*}
        done

        if [[ "${on_tmpfs}" = false ]]; then
            tmp_located_on=""
            defifs=${IFS} && IFS=$'\n'
            for line in $(df | tr -s ' ')
            do
                if echo ${line} | cut -d' ' -f6 | grep ^${tmp}$ &>/dev/null; then
                    tmp_located_on="$(echo ${line} | cut -d' ' -f1)"
                fi
            done
            IFS=${defifs}
            [[ "x${tmp_located_on}" = "x" ]] && tmp_located_on="/"

            shmtmp="/dev/shm/${tmp}"
            mkdir -p ${shmtmp}
            chmod 1777 ${shmtmp}
            files=(${tmp}/*)
            [[ -e ${files} ]] && cp -pr ${tmp}/* ${shmtmp}
            mount --bind ${shmtmp} ${tmp}

            mkdir ${mntpnt_orig_tmp}
            if [[ ${tmp_located_on} = "/" ]]; then
                mount_opts="--bind"
                tmp_path="${mntpnt_orig_tmp}/${tmp}"
            else
                mount_opts=""
                tmp_path="${mntpnt_orig_tmp}"
            fi
            mount ${mount_opts} ${tmp_located_on} ${mntpnt_orig_tmp}

            files=(${tmp_path}/*)
            [[ -e ${files} ]] && rm -rf ${tmp_path}/*
            umount ${mntpnt_orig_tmp} && rm -rf ${mntpnt_orig_tmp}
        fi
    done
}

function _clean_yum_uuid() {
    uuid="/var/lib/yum/uuid"
    [[ -e ${uuid} ]] && rm -rf ${uuid} || :
}

function _clean_logins() {
    login_logs=(
        "/var/log/lastlog"
        "/var/log/wmtp"
        "/var/log/btmp"
        "/var/run/utmp"
        "/var/run/utmp"
    )
    for login_log in ${login_logs[@]}; do ln -sfn /dev/null $login_log; done
}

_clean_shell_history
_clean_home_dirs
_clean_cloud_init
_clean_logs
_clean_crash_data
_reset_dhcp_state
_reset_fw_rules
_reset_machine_id
_clean_mail_spool
_clean_package_manager_cache
_clean_package_manager_db
_clean_tmp
_clean_yum_uuid
_clean_logins

exit 0
