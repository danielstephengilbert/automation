#!/bin/bash

# Create VBox Win11 VM

# Automate VirtualBox VM creation for Windows 11 Pro VMs.
# I may create other versions of this for different operating systems later.
# Created by Daniel Gilbert on Jan 11, 2025.

# Usage:
# ./create_vbox_win11 <vm_name> <iso_path>
# Creates a new VM in a subdirectory of the current directory based on ISO.

# NOTE:
# This script only creates the configurations.
# You still have to run the VM using: vboxmanage startvm <vm_name>.
# The only input required is pressing enter at the start of the install.
# This input is required by UEFI to boot from external media.

# Get user input
script_name=$0
vm_name=$1
os_iso_path=$2

# Require parameters
if [[ -z $vm_name || -z $os_iso_path ]]; then
  echo "Usage: $script_name <vm_name> <iso_path>"
  exit 1
fi

# Configure VM path and config 
vm_basefolder=$(pwd)
vm_folder="${vm_basefolder}/${vm_name}"
vm_os="Windows11_64"
vm_size=65536                           # In megabytes
os_image_index=6                        # Win11 Pro (Use the # not the [X])
os_user="user"
os_password="user"

# Create and register the VM with VirtualBox
vboxmanage createvm               \
  --basefolder  "$vm_basefolder"  \
  --name        "$vm_name"        \
  --ostype      "$vm_os"          \
  --default                       \
  --register

# Create the virtual disk
vboxmanage createmedium disk                    \
  --filename    "${vm_folder}/${vm_name}.vdi"   \
  --size        $vm_size

# Attach the virtual disk
vboxmanage storageattach "$vm_name"             \
  --storagectl  "SATA"                          \
  --port        0                               \
  --type        "hdd"                           \
  --medium      "${vm_folder}/${vm_name}.vdi"

# Enable bidirectional clipboard
vboxmanage modifyvm "$vm_name"      \
  --clipboard-mode  bidirectional

# Create the unattended install configuration file
vboxmanage unattended install "$vm_name"  \
  --iso           "$os_iso_path"          \
  --image-index   "$os_image_index"       \
  --country       "US"                    \
  --user          "$os_user"              \
  --password      "$os_password"          \
  --install-additions

# Modify the unattended install config file to supply a blank product key
os_config_file=`find "${vm_folder}" | grep autounattend`
sed -i '/<ProductKey>/a <Key></Key>' "$os_config_file"

# Print next steps
echo ""
echo "Configuration complete."
echo "If no errors, start the vm using:"
echo "vboxmanage startvm <vm_name>"
echo "You should only need to press enter to boot the installation media."


