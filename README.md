# gnu/linux -> proxmox lxc container #

#### root ssh access/rsync on target machine required ##### 
#### run skript @proxmox host as root ##### 

```
./convert.sh \
-n intern05 \
-t intern05.dgmbsd.de \
-i 109 \
-s 60 \
-a 192.168.111.59 \
-b vmbr0 \
-g 192.168.111.64 \
-m 2048 \
-d default \
-p dgmadm

```

```
./convert.sh -h|--help
 -n|--name <target ct name>
 -t|--target <target machine uri>
 -i|--id <proxmox id>
 -s|--root-size <rootfs size in GB>
 -ip|--ip <target ct ip>
 -b|--gateway <gatewayinterface>
 -g|--gateway <gatewayip>
 -m|--memory <memory in mb>
 -p|--password <root password for ct>
 -st|--storage)    storage $2; shift 2;;


```
