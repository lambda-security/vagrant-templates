#!/bin/bash
set -eo pipefail

usage() {
    printf "%s\n" \
        "-u|--up                bring environment up, build the first time" \
        "                       specify multiple vms by comma or \"all\"" \
        "" \
        "-d|--down              bring environment down" \
        "                       specify multiple vms by comma or \"all\"" \
        "" \
        "-s|--snapshot <name>   take environment snapshot with <name>" \
        "" \
        "-r|--restore <name>    restore environment snapshot with <name>" \
        "" \
        "-x|--delete <name>     delete envionment snapshot with <name>" \
        "" \
        "-l|--list              list snapshots" \
        "" \
        "--status               vagrant environment status" \
        "" \
        "-z|--destroy           destroy environment" \
        "                       specify multiple vms by comma or \"all\"" \
        "" \
        "-f|--force             force" \
        "" \
        "-h|--help              print this help message and exit" && exit 1
}

force=false

options=$(getopt -o u:d:s:r:x:lz:fh --long up:,down:,snapshot:,restore:,delete:,list,status,destroy:,force,help -n "$(basename $0)" -- "$@")
eval set -- "$options"
while true; do
    case "$1" in
        -u|--up)            action="up";        vms="$2"; shift;;
        -d|--down)          action="down";      vms="$2"; shift;;
        -s|--snapshot)      action="snapshot";  snapshot_name="$2"; shift;;
        -r|--restore)       action="restore";   snapshot_name="$2"; shift;;
        -x|--delete)        action="delete";    snapshot_name="$2"; shift;;
        -l|--list)          action="list";;
        --status)           action="status";;
        -z|--destroy)       action="destroy";   vms="$2"; shift;;
        -f|--force)         force=true;;
        -h|--help)          usage;;
        --)                 shift; break;;
        *)                  printf "%s\n" "invalid option: $1" >&2; usage;;
    esac
    shift
done

[[ -z $action ]] && usage
case $vms in
    all) items="";;
    *)   items=$(printf "%s" "${vms}" | tr ',' ' ');;
esac

case $action in
    up)         cmd="vagrant up";;
    down)       cmd="vagrant halt";;
    snapshot)   cmd="vagrant snapshot save ${snapshot_name}";;
    restore)    cmd="vagrant snapshot restore --no-start ${snapshot_name}";;
    delete)     cmd="vagrant snapshot delete ${snapshot_name}";;
    list)       cmd="vagrant snapshot list";;
    status)     cmd="vagrant status";;
    destroy)    cmd="vagrant destroy";;
esac

if [[ $action = up ]] || [[ $action = down ]] || [[ $action = destroy ]]; then
    cmd="$cmd $items"
fi
[[ $force = true ]] && cmd="$cmd --force"

eval "$cmd"
