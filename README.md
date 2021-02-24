# convert any gnu/linux machine into a proxmox lxc container #

#### root ssh access/rsync on target machine required ##### 
#### run skript @proxmox host with root privileges ##### 

```
./convert.sh \
-n foo \
-t bar.memswap-realms.com \
-i 113 \
-s 10 \
-a 192.168.111.62 \
-b vmbr0 \
-g 192.168.111.64 \
-m 2048 \
-d default \
-p foo

```

```
/convert.sh -h|--help
 -n|--name [lxc container name]
 -t|--target [target machine ssh uri]
 -i|--id [proxmox cntainer id]
 -s|--root-size [rootfs size in GB]
 -a|--ip [target container ip]
 -b|--bridge [bridge interface]
 -g|--gateway [gateway ip]
 -m|--memory [memory in mb]
 -d|--diskstorage [target proxmox storage pool]
 -p|--password [root password for container]
```
