#!/bin/bash
usage()
{
    cat <<EOF
$1 -h|--help
 -n|--name=<target ct name>
 -t|--target=<target machine uri>
 -i|--id=<proxmox id>
 -s|--root-size=<rootfs size in GB>
 -a|--ip=<target ct ip>
 -b|--gateway=<gatewayinterface>
 -g|--gateway=<gatewayip>
 -m|--memory=<memory in mb>
 -d|--diskstorage=<target storage>
 -p|--password=<root password for ct>
EOF
    return 0
}
options=$(getopt -o n:t:i:s:a:b:g:m:d:p:f -l help,name:,target:,id:,root-size:,ip:,bridge:,gateway:,memory:,diskstorage:,password:,foo: -- "$@")
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
        -a|--ip)       ip=$2; shift 2;;
        -b|--bridge)    bridge=$2; shift 2;;
        -g|--gateway)   gateway=$2; shift 2;;
        -m|--memory)    memory=$2; shift 2;;
        -p|--password)  password=$2; shift 2;;
        -d|--diskstorage) storage=$2; shift 2;;
        --)             shift 2; break ;;
        *)              break ;;
    esac
done

#echo $name
#echo $target
#echo $id
#echo $rootsize
#echo $ip
#echo $bridge
#echo $gateway
#echo $password
#echo $storage
#echo $memory
#exit
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

rm -rf /tmp/$name*
