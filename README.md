# gnu/linux -> proxmox lxc container #

#### root ssh access/rsync on target machine required ##### 
#### run skript @proxmox host as root ##### 

```
./convert.sh \ 
- n intern04 \ 
- t intern04.dgmbsd.de \ 
- i 111  \ 
- s 60 \ 
- ip 192.168.111.60 \ 
- b vmbr0 \ 
- g 192.168.111.64 \ 
- m 2048 \ 
- p foo

```

```
./convert.sh -h|--help
 -n|--name=<target ct name>
 -t|--target=<target machine uri>
 -i|--id=<proxmox id>
 -s|--root-size=<rootfs size in GB>
 -ip|--ip=<target ct ip>
 -b|--gateway=<gatewayinterface>
 -g|--gateway=<gatewayip>
 -m|--memory=<memory in mb>
 -p|--password=<root password for ct>

```
