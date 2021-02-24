#!/bin/bash
usage()
{
    cat <<EOF
$1 -h|--help
 -n|--name=<target ct name>
 -t|--target=<target machine uri>
 -i|--id=<proxmox id>
 -s|--root-size=<rootfs size in GB>
 -ip|--ip=<target ct ip>
 -b|--gateway=<gatewayinterface>
 -g|--gateway=<gatewayip>
 -m|--memory=<memory in mb>
 -p|--password=<root password for ct>
 -st|--storage=<target storage>
EOF
    return 0
}
options=$(getopt -o n:t:i:s:ip:b:g:m:p:st -l help,name:,target:,id:,root-size:,ip:,bridge:,gateway:,memory:,password:,storage: -- "$@")
if [ $? -ne 0 ]; then
        usage $(basename $0)
    exit 1
fi
eval set -- "$options"
while true
do
    case "$1" in
        -h|--help)      usage $0 && exit 0;;
        -n|--name)      name=$2; shift 2;;
        -t|--target)    target=$2; shift 2;;
        -i|--id)        id=$2; shift 2;;
        -s|--root-size) rootsize=$2; shift 2;;
        -ip|--ip)       ip=$2; shift 2;;
        -b|--bridge)    bridge=$2; shift 2;;
        -g|--gateway)   gateway=$2; shift 2;;
        -m|--memory)    memory=$2; shift 2;;
        -p|--password)  pass=$2; shift 2;;
        -st|--storage)  storage=$2; shift 2;;
        --)             shift 1; break ;;
        *)              break ;;
    esac
done

echo $name
echo $target
echo $id
echo $rootsize
echo $ip
mkdir -p /tmp/$name/rootfs
rsync -e ssh -a \
  --exclude '*.log' \
  --exclude '*.gz' \
  --exclude '*.sql' \
  --exclude '/swap.img' \
  --exclude '/swap.img' \
  --exclude '/dev' \
  --exclude '/proc' \
  --exclude '/sys' \
  root@$target:/ /tmp/$name/rootfs --progress

tar -czvf /tmp/$name.tar.gz -C /tmp/$name/rootfs/ .

pct create $id /tmp/$name.tar.gz \
  -description LXC \
  -hostname $name \
  -memory  $memory -nameserver 8.8.8.8 \
  -net0 name=eth0,ip=$ip/24,gw=$gateway,bridge=$bridge \
  --rootfs $rootsize -storage $storage -password $pass

rm /tmp/$name.tar.gz
