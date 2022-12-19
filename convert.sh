#!/bin/bash
if ! command -v pct &> /dev/null
then
    echo "pct could not be found. This script must be run on the host machine proxmox"
    exit 1
fi
usage()
{
    cat <<EOF
$1 -h|--help
 -n|--name [lxc container name]
 -t|--target [target machine ssh uri]
 -P|--port [target port ssh]
 -i|--id [proxmox container id]
 -s|--root-size [rootfs size in GB]
 -a|--ip [target container ip]
 -b|--bridge [bridge interface]
 -g|--gateway [gateway ip]
 -m|--memory [memory in mb]
 -d|--disk-storage [target proxmox storage pool]
 -p|--password [root password for container (min. 5 chars)]
EOF
    return 0
}

options=$(getopt -o n:t:P:i:s:a:b:g:m:d:p:f -l help,name:,target:,port:,id:,root-size:,ip:,bridge:,gateway:,memory:,disk-storage:,password:,foo: -- "$@")
if [ $? -ne 0 ]; then
        usage "$(basename "$0")"
    exit 1
fi
eval set -- "$options"

while true
do
    case "$1" in
        -h|--help)          usage "$0" && exit 0;;
        -n|--name)          name=$2; shift 2;;
        -t|--target)        target=$2; shift 2;;
        -P|--port)          port=$2; shift 2;;
        -i|--id)            id=$2; shift 2;;
        -s|--root-size)     rootsize=$2; shift 2;;
        -a|--ip)            ip=$2; shift 2;;
        -b|--bridge)        bridge=$2; shift 2;;
        -g|--gateway)       gateway=$2; shift 2;;
        -m|--memory)        memory=$2; shift 2;;
        -p|--password)      password=$2; shift 2;;
        -d|--disk-storage)  storage=$2; shift 2;;
        --)                 shift 2; break ;;
        *)                  break ;;
    esac
done

collectFS() {
    tar -czvvf - -C / \
	--exclude="sys" \
	--exclude="dev" \
	--exclude="run" \
	--exclude="proc" \
	--exclude="*.log" \
	--exclude="*.log*" \
	--exclude="*.gz" \
	--exclude="*.sql" \
	--exclude="swap.img" \
	.
}

ssh -p"$port" "root@$target" "$(typeset -f collectFS); collectFS" \
    > "/tmp/$name.tar.gz"

pct create "$id" "/tmp/$name.tar.gz" \
  -description LXC \
  -hostname "$name" \
  --features nesting=1 \
  -memory "$memory" -nameserver 8.8.8.8 \
  -net0 name=eth0,ip="$ip"/24,gw="$gateway",bridge="$bridge" \
  --rootfs "$rootsize" -storage "$storage" -password "$password"

rm -rf "/tmp/$name.tar.gz"
