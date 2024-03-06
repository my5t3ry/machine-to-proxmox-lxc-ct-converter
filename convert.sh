#!/bin/bash

checkList()
{
    # Check if running as root
    if [ "$(whoami)" != "root" ]; then
        echo -e "\e[96mLog in as a superuser...\e[39m"
        sudo -E bash "$0" "$@"
        exit $?
    fi

    # Check if the 'pct' command is available on the host machine (proxmox)
    if ! command -v pct &> /dev/null; then
        whiptail --title "Error" --msgbox "The 'pct' command could not be found. This script must be run on the Proxmox host machine." 10 60
        exit 1
    fi

    # Check if the 'sshpass' command is available on the host machine
    if ! command -v sshpass &> /dev/null; then
        # Install 'sshpass' using apt-get
        apt-get install -y sshpass

        # Check if the installation was successful
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install 'sshpass'. Exiting."
            exit 1
        fi
    fi
}

# Function to display welcome message
welcome()
{
    whiptail --title "GNU/Linux Machine to Proxmox LXC Container Converter" --msgbox \
    "This script simplifies converting a linux machine to a Proxmox LXC container. Follow the prompts to provide details, and the script will handle the conversion seamlessly.

    Please note:
    - Ensure that the 'pct' command is available on your Proxmox host machine.
    - If 'pct' or 'sshpass' is not available, the script will attempt to install 'sshpass' in the background.
    - For additional options or in case of issues, you can use './bashconvert -h'.

    If you need help or encounter issues, visit the repository for assistance.

    Repository Link: https://github.com/my5t3ry/machine-to-proxmox-lxc-ct-converter

    Let's get started!" 23 70
}

# Function to create an interactive menu
createMenu() 
{
    local title=$1
    local prompt=$2

    local input
    input=$(whiptail --title "$title" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        echo "$input"
    else
        whiptail --title "Error" --msgbox "Canceled. Exiting the script." 10 60
        exit 1
    fi
}

# Function to display a selection menu for Bridge
selectBridge() 
{
    local bridges=($(brctl show | awk 'NR>1 && /^vmbr/ {print $1}'))

    if [ ${#bridges[@]} -eq 0 ]; then
        whiptail --title "Error" --msgbox "No Proxmox bridge interfaces found." 10 60
        exit 1
    fi

    local options=()
    for bridge in "${bridges[@]}"; do
        options+=("$bridge" "")
    done

    local choice
    choice=$(whiptail --title "Bridge Selection" --menu "Choose a Proxmox bridge interface:" 15 60 6 "${options[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        echo "$choice"
    else
        whiptail --title "Error" --msgbox "Operation canceled. Exiting the script." 10 60
        exit 1
    fi
}

# Function to choose between DHCP, manual IP configuration, or copying VM's network settings
selectIPConfig() 
{
    local choice

    choice=$(whiptail --title "IP Configuration" --menu "Choose network configuration:" 15 60 6 \
        "1" "Use DHCP" \
        "2" "Manual IP Configuration" 3>&1 1>&2 2>&3)

    case "$choice" in
        "1")
            ip="dhcp"
            gateway="dhcp"
            ;;
        "2")
            ip=$(createMenu "Container IP" "Enter the target container IP:")
            gateway=$(createMenu "Gateway IP" "Enter the gateway IP:")
            ;;
        *)
            whiptail --title "Error" --msgbox "Invalid choice. Exiting the script." 10 60
            exit 1
            ;;
    esac
}

# Interactive menu to get user input
userInput() 
{
    # Get ID and NAME for LXC container
    id=$(createMenu "Proxmox Container ID" "Enter the Proxmox container ID:")
    name=$(createMenu "Container Name" "Choose a name for the LXC container:")

    # Get target machine SSH URI, SSH port, and SSH password
    target=$(createMenu "Target Machine" "Enter the target machine SSH URI:")
    port=$(createMenu "SSH Port" "Enter the target SSH port:")
    passwordSSH=$(createMenu "SSH Password" "Enter the SSH password for the target machine:")

    # Get bridge & network configurations
    bridge=$(selectBridge)
    selectIPConfig

    # Get Container configurations
    rootsize=$(createMenu "RootFS Size" "Enter the rootfs size in GB:")
    memory=$(createMenu "Memory" "Enter the memory in MB:")
    storage=$(createMenu "Storage Pool" "Enter the target Proxmox storage pool:")
    passwordCT=$(whiptail --title "Root Password" --inputbox "Enter the root password for the container (min. 5 chars):" 10 60 --cancel-button "Cancel" 3>&1 1>&2 2>&3)
}

# Function to collect file system data, excluding unnecessary directories and files
collectFS() 
{
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

# Function to validate input parameters
validateParameters() 
{
    if [ -z "$name" ] || [ -z "$target" ] || [ -z "$port" ] || [ -z "$id" ] || [ -z "$rootsize" ] || [ -z "$ip" ] || [ -z "$bridge" ] || [ -z "$gateway" ] || [ -z "$memory" ] || [ -z "$storage" ] || [ -z "$passwordCT" ] || [ -z "$passwordSSH" ]; then
        whiptail --title "Error" --msgbox "Missing required parameters." 10 60
        exit 1
    fi

    if [ ${#passwordCT} -lt 5 ]; then
        whiptail --title "Error" --msgbox "Password must be at least 5 characters." 10 60
        exit 1
    fi
}

# Function to convert VM to Proxmox LXC container
convert() 
{
    # Step 0: SSH into the target machine and collect file system data in the background
    sshpass -p "$passwordSSH" ssh -p "$port" -o "StrictHostKeyChecking=no" "root@$target" "$(typeset -f collectFS); collectFS" > "/tmp/$name.tar.gz"

    # Set default values for DHCP
    ip_param="-net0 name=eth0,bridge=$bridge,ip=dhcp"

    # Check if manual IP configuration is chosen
    if [ "$ip" != "dhcp" ]; then
        ip_param="-net0 name=eth0,bridge=$bridge,ip=$ip/24,gw=$gateway"
    fi

    # Step 2: Create a Proxmox container using the collected file system data and provided parameters
    if pct create "$id" "/tmp/$name.tar.gz" \
        -description LXC \
        -hostname "$name" \
        --features nesting=1 \
        -memory "$memory" -nameserver 8.8.8.8 \
        $ip_param \
        --rootfs "$rootsize" -storage "$storage" -password "$passwordCT"; then
        whiptail --title "Success" --msgbox "Proxmox container created successfully!" 10 60
    else
        whiptail --title "Error" --msgbox "Failed to create Proxmox container." 10 60
    fi
                
    # Step 3: Remove the temporary file
    rm -rf "/tmp/$name.tar.gz"
}

# Main Function
main() 
{
    welcome
    checkList
    userInput
    validateParameters
    convert
}
main