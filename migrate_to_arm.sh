#!/bin/bash -
#title          : migrate_to_arm.sh
#description    : The script will generate command to install non available package in new system
#author         : totoshko88@gmail.com
#date           : 20220512
#version        : 1.0
#usage          : ./migrate_to_arm.sh
#notes          : 
#bash_version   : 5.2.15
#============================================================================

if [ "$EUID" -ne 0 ]
    then echo "Please run $0 as a superuser"
    exit
fi

# Check if package list file is provided
if [ -z "$1" ]; then
    echo "Please provide the path to the package list file as an argument."
    echo "Usage: $0 <package-list-file>"
    exit 1
fi

# Check if the system is running Ubuntu or Debian
if [ -f "/etc/os-release" ]; then
    os_info=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
    if [ "$os_info" != "ubuntu" ] && [ "$os_info" != "debian" ]; then
        echo "This script is intended for Debian-based systems (Ubuntu/Debian)."
        echo "Your system appears to be running $os_info."
        exit 1
    fi
else
    echo "This script is intended for Debian-based systems (Ubuntu/Debian)."
    echo "Unable to determine the operating system."
    exit 1
fi

# Check system architecture
if [ "$(dpkg --print-architecture)" != "arm64" ]; then
    echo "This script is intended for arm64 architecture only."
    echo "Your system architecture is $(dpkg --print-architecture)."
    exit 1
fi

input_file=$(<"$1")
# modify architecture
package_to_install="${input_file//':amd64'/:arm64}"

# exclude linux kernel
package_to_install=$(echo "$package_to_install" | grep -vE 'linux-(headers|image|modules|aws)-')

# exclude architecture
package_to_install=$(echo "$package_to_install" | sed 's/:arm64//g')

# exlude installed
installed_package=$(dpkg-query -W -f='${Package}\n')

package_to_install=$(comm -23 <(printf '%s\n' "${package_to_install[@]}" | sort) <(printf '%s\n' "${installed_package[@]}" | sort))

# Check package availability

non_available_packages=()

for package in $package_to_install; do
candidate_version=$(apt-cache policy "$package" | awk '/Candidate:/ {print $2}'); 
if [[ $candidate_version == "(none)" ]]; then
    non_available_packages+=("$package")
fi
done

# exclude non available
package_to_install=$(comm -23 <(printf '%s\n' "${package_to_install[@]}" | sort) <(printf '%s\n' "${non_available_packages[@]}" | sort))

# check to install
if [ -z "$package_to_install" ]; then
    echo "Everything is already installed, nothing needs to be done."
    exit 0
fi

# Prompt for confirmation
echo "The following packages will be installed:"
echo $package_to_install
read -rp "Do you want to proceed with the installation? (y/n): " confirm

# Execute installation command if confirmed
if [[ "$confirm" == "y" ]]; then
    echo "Executing the installation command..."
    dpkg --configure -a && apt update && yes | apt install $package_to_install
else
    echo "Installation cancelled by the user."
fi

exit 0