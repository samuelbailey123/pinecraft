#!/bin/bash

# This will ensure the script exits if a command fails
set -e

# Check if dialog is installed
if ! type -p dialog >/dev/null; then
  echo "Installing dialog..."
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install -y dialog >/dev/null 2>&1
fi

# Minimum and maximum versions of Java required
javaminver=8
javamaxver=17

# Set a flag to track if repository update is needed before installations
updated=0

# Prepare list of packages to install
packages_to_install=""

# Helper function to add package if not installed
add_package_if_missing() {
  local pkg=$1
  if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
    packages_to_install+=" $pkg"
  fi
}

# Add git, screen, wget, and cron if not installed
add_package_if_missing git
add_package_if_missing screen
add_package_if_missing wget
add_package_if_missing cron

# Install compilers if needed by checking compiler variable
if [[ $compiler == 1 ]]; then
  add_package_if_missing gcc
  add_package_if_missing g++
  add_package_if_missing cmake
fi

# If there are packages to install, update repository and install them
if [[ -n $packages_to_install ]]; then
  echo "Installing required packages..."
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install -y $packages_to_install >/dev/null 2>&1
fi

# Java installation loop
for ((ver=$javamaxver; ver >= $javaminver; ver--)); do
  if dpkg-query -W -f='${Status}' "openjdk-${ver}-jre-headless" 2>/dev/null | grep -q "install ok installed"; then
    echo "Java version ${ver} is already installed."
    break
  else
    echo "Trying to install openjdk-${ver}-jre-headless..."
    sudo apt-get install -y "openjdk-${ver}-jre-headless" >/dev/null 2>&1 && break
  fi
done

# Check if Java is installed, if not, install the latest
if ! type -p java >/dev/null; then
  echo "Java not found, installing the latest version..."
  sudo apt-get install -y default-jre-headless >/dev/null 2>&1
fi

# Configure Java after installation
if type -p java >/dev/null; then
  # Extract version strings and compare
  javaver=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  read -a javaversion <<< $(echo $javaver | tr "." " ")
  if (( ${javaversion[0]} <= 1 && ${javaversion[1]} < javaminver )); then
    dialog --title "Error" \
        --msgbox "\nYour Java version is ${javaver}. You need at least Java ${javaminver}." 8 50
    exit 1
  fi
  JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
  export JAVA_HOME
  echo "export JAVA_HOME=$JAVA_HOME" >> ~/.profile
  source ~/.profile
else
  dialog --title "Error" \
      --msgbox "\nJava installation failed. Please install Java manually and try again." 8 50
  exit 1
fi

# Unset git `core.autocrlf` if set
git config --global --unset core.autocrlf || true

# Final message
dialog --title "Success" --msgbox "All required software is installed and configured." 6 50
