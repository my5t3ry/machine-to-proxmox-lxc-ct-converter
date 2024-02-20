# GNU/Linux Machine to Proxmox LXC Container Converter

[![GitHub contributors](https://img.shields.io/github/contributors/my5t3ry/machine-to-proxmox-lxc-ct-converter.svg)](https://github.com/my5t3ry/machine-to-proxmox-lxc-ct-converter/contributors)
[![GitHub stars](https://img.shields.io/github/stars/my5t3ry/machine-to-proxmox-lxc-ct-converter.svg)](https://github.com/my5t3ry/machine-to-proxmox-lxc-ct-converter/stargazers)

This script simplifies the process of converting a Machine/VM linux into a Proxmox LXC container. Follow the prompts to provide essential details, and the script will handle the conversion seamlessly.

## Prerequisites

- This script must be run on the Proxmox host machine.
- Ensure that the 'pct' command is available on your Proxmox host machine.

## Installation

1. Clone this repository on the Proxmox host machine and give execution permissions to the scripts:

    ```bash
    git clone https://github.com/mathewalves/machine-to-proxmox-lxc-ct-converter.git
    cd machine-to-proxmox-lxc-ct-converter
    chmod +x convert.sh bashconvert
    ```

2. Run the script as a root:

    ```bash
    ./convert.sh
    ```

## Usage

1. Run the script and follow the interactive prompts to provide necessary details for the conversion.

2. The script will initiate the conversion process. Note that you need the SSH key of the machine and the SSH port.

3. Once the conversion is complete, the Proxmox LXC container will be created.

## Options & Alternatives

If desired, use ./bashconvert to perform the conversion process using Bash.
```bash
./bashconvert -h |--help
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
 ```

 Customize as needed based on your specific requirements.



## Troubleshooting

- If 'pct' or 'sshpass' is not available, the script will attempt to install 'sshpass' in the background.