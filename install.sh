#!/bin/bash
pcver="3.9"

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root" 2>&1
  exit 1
fi

# Install debs script
./debs.sh

# Check if the last command (./debs.sh) succeeded
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to run debs.sh" >&2
  exit 1
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get the LAN IP address

  # test the route based on $host and treat that as the interface
  interface=""
  host=github.com
  host_ip=$(getent ahosts "$host" | awk '{print $1; exit}')
  interface=`ip route get "$host_ip" | grep -Po '(?<=(dev )).*(?= src| proto)' | cut -f 1 -d " "`
  ip=$(/sbin/ip -f inet addr show $interface | grep -Po 'inet \K[\d.]+' | head -n 1)
  if [[ $ip == "" ]]; then
    # Never reply with a blank string - instead, use localhost if no IP is found
    # This would be the case if no network connection is non-existent
    ip="127.0.0.1"
  fi

# Determine where the config.txt file is
  # Generic
  configfile=/boot/config.txt
  # Ubuntu
  if [[ -e /boot/firmware/config.txt ]]; then
    configfile=/boot/firmware/config.txt
  fi

# Version comparison which allows comparing 1.16.5 to 1.14.0 (for example)
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Place the current folder in a variable to use as a base source folder
base=$(pwd)

mcver="1.20.4"

# Username may be provided on CLI as in 1.0
user=$1

if [[ $user == "" ]]; then
  validuser=""
else
  validuser=$(getent passwd $user)
fi
while [[ $validuser == "" ]]
do

  users=$(cat /etc/passwd | grep '/home' | cut -d: -f1)
  count=1
  declare -a usersarr=()
  for username in $users; do
    if [[ -d /home/${username}/ ]]; then
      usersarr+=("${username}" "/home/${username}/minecraft/")
    fi
  done

  exec 3>&1
  user=$(dialog --title "Linux User" --menu "Linux User to run Minecraft Server:" 20 50 10 "${usersarr[@]}" 2>&1 1>&3);

  case $? in
  0)
   if [[ $user == "" ]]; then
    validuser=""
   else
    validuser=$(getent passwd $user)
   fi
   if [[ $validuser == "" ]]; then
     dialog --title "Error" \
       --msgbox "\n $user does not exist." 6 50
   fi
   ;;
  1)
   echo
   echo
   echo "Aborted."
   echo
   exit 1 ;;
  esac
done

instdir="/home/$user/minecraft/"

upgrade=0
replace=0
if [[ -e /home/$user ]]; then
  minecraft_dir="/home/$user/minecraft"
  if [[ -e ${minecraft_dir} ]]; then
    # The directory /home/$user/minecraft exists, so we give the user
    # the option to upgrade or replace their current installation.

    exec 3>&1
    result=$(dialog --title "Pinecraft Installer $pcver" \
       --menu "Pinecraft is already installed:" 9 40 4 \
       "U"       "Upgrade Software (Keep World)" \
       "R"       "Remove Previous and Reinstall" \
      2>&1 1>&3);

    if [[ $? == 0 ]]; then
      case $result in
        U)
          upgrade=1
          ;;
        R)
          dialog --title "Confirmation"  --yesno "\nThis will remove your entire previous installation, including your world files.\n\nContinue?" 12 50
          case $? in
            1)
            echo
            echo
            echo "Aborted."
            echo
            exit 1 ;;
          esac
          replace=1
          ;;
        esac
      else
        echo
        echo
        echo "Aborted."
        echo
        exit 1
      fi
    fi
else
  echo "Aborting: $user does not have a homedir."
  exit 1
fi

# Get the level seed, but only if this is a new install
if [[ $upgrade == 0 ]]; then
  exec 3>&1
  result=$(dialog --title "Pinecraft Installer $pcver" \
         --menu "Choose your game seed:" 20 50 10 \
         "A"       "Random (Default, ${mcver})" \
         "B"       "Custom (${mcver})" \
       2>&1 1>&3);

  if [[ $? == 0 ]]; then
    case $result in
    A)
      seed=""
      mcverANY=1
      ;;
    B)
      seed="custom"
      mcverANY=1
      ;;
    esac
  else
    echo
    echo
    echo "Aborted."
    echo
    exit 1
  fi

  # Input custom seed
  if [[ $seed == "custom" ]]; then
    seed=$(dialog --stdout --title "Custom World Seed" \
      --inputbox "Enter your custom world seed" 8 50)
  fi

fi

# https://www.minecraft.net/en-us/download/server
if [[ $mcver == "1.20.4" ]]; then
    vanilla="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
else
  # 1.16.5
  vanilla="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
fi
flavor=""

declare -a flavors=()

if [[ $mcverANY == "1" ]] || [[ $mcver == "1.17.1" ]] || [[ $mcver == "1.17" ]] || [[ $mcver == "1.16.5" ]] || [[ $mcver == "1.18" ]] || [[ $mcver == "1.18.1" ]] || [[ $mcver == "1.18.2" ]] || [[ $mcver == "1.19" ]] || [[ $mcver == "1.19.2" ]] || [[ $mcver == "1.19.3" ]] || [[ $mcver == "1.19.4" ]] || [[ $mcver == "1.20.1" ]] || [[ $mcver == "1.20.2" ]] || [[ $mcver == "1.20.4" ]]; then
  flavors+=("V" "Vanilla (${mcver})")
fi

exec 3>&1
result=$(dialog --title "Pinecraft Installer $pcver" --menu "Choose your Minecraft server type:" 20 40 10 "${flavors[@]}" 2>&1 1>&3);

if [[ $? == 0 ]]; then
  case $result in
    V)
      flavor="Vanilla"
      url=$vanilla
      jarname="server.jar"
      switches=""
      ;;
    esac
else
  echo
  echo
  echo "Aborted."
  echo
  exit 1
fi
if [[ $flavor == "" ]]; then
  echo
  echo
  echo "Aborted."
  echo
  exit 1
fi

exec 3>&1
result=$(dialog --title "Pinecraft Installer $pcver $mcver" \
         --menu "Choose your game type:" 20 40 10 \
         "S"       "Survival" \
         "C"       "Creative" \
       2>&1 1>&3);

if [[ $? == 0 ]]; then
  case $result in
    S)
      gamemode="survival"
      ;;
    C)
      gamemode="creative"
      ;;
    esac
else
  echo
  echo
  echo "Aborted."
  echo
  exit 1
fi

dialog --title "End-User License Agreement"  --yesno "In order to proceed, you must read and accept the EULA at https://account.mojang.com/documents/minecraft_eula\n\nDo you accept the EULA?" 8 60

  case $? in
  0)
   eula="accepted"
   eula_stamp=$(date)
   ;;
  1)
   echo
   echo
   echo "EULA not accepted. You are not permitted to install this software."
   echo
   exit 1 ;;
  esac

# Gather some info about your system which will be used to determine the config
revision=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}')
if [[ $revision == "" ]]; then
  revision=$(cat /proc/cpuinfo | grep 'Hardware' | awk '{print $4}')
fi
board="Unknown" # Default will be overridden if determined
memtotal=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}') # Amount of memory in KB
memavail=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}') # Amount of memory in KB
memvariance=$(($memtotal - $memavail)) # Figure out how much memory is being used so we can make dynamic decisions for this board
mem=$(( (($memtotal - $memvariance) / 1024) - 518)) # Amount of memory in MB
memreservation=$((($memavail * 20/100) / 1024)) # Reserve memory for system (Failure to do this will cause "Error occurred during initialization of VM")
gamemem=$(($mem - $memreservation)) # Calculate how much memory we can give to the game server (in MB)
gamememMIN=$((($mem * 80/100) - 1024)) # Figure a MINIMUM amount of memory to allocate
# Seriously, if you have 100 GB RAM, we don't need more than 20 of it
if (( $gamemem > 20000 )); then
    gamemem=20288
    gamememMIN=1500
fi
oc_volt=0
oc_friendly="N/A"
if (( $gamememMIN < 0 )); then
  dialog --title "Error" \
    --msgbox "
YOU DON'T HAVE ENOUGH AVAILABLE RAM

Your system shows only $((${memavail} / 1024))MB RAM available, but with the applications running you have only $mem MB RAM available for allocation, which doesn't leave enough for overhead. Typically I'd want to be able to allocate at least 2 GB RAM.

Either you have other things running, or your board is simply not good enough to run a Minecraft server." 18 50
   echo
   echo
   echo "Failed. Not enough memory available for Minecraft server."
   echo
   exit 0
fi

if
   [[ "$revision" == *"a03111" ]] ||
   [[ "$revision" == *"b03111" ]] ||
   [[ "$revision" == *"b03112" ]] ||
   [[ "$revision" == *"b03114" ]] ||
   [[ "$revision" == *"b03115" ]] ||
   [[ "$revision" == *"c03111" ]] ||
   [[ "$revision" == *"c03112" ]] ||
   [[ "$revision" == *"c03114" ]] ||
   [[ "$revision" == *"c03115" ]] ||
   [[ "$revision" == *"d03114" ]] ||
   [[ "$revision" == *"d03115" ]]; then
     board='Raspberry Pi 4'
     boardnum=1
     oc_volt=4
     oc_freq=1900
     oc_friendly="1.9 GHz"
elif [[ "$revision" == *"c03130" ]]; then
  board='Raspberry Pi 400'
  boardnum=2
  oc_volt=6
  oc_freq=2000
  oc_friendly="2.0 GHz"
elif [[ "$revision" == *"VIM4" ]]; then
  board='Khadas VIM4'
  boardnum=3
  oc_friendly="Not Required"

fi

if (( $gamemem > 3800 )); then
  kernel=$(uname -a)
  if [[ ! "$kernel" == *"amd64"* ]] && [[ ! "$kernel" == *"arm64"* ]] && [[ ! "$kernel" == *"aarch64"* ]] && [[ ! "$kernel" == *"x86_64"* ]]; then

    dialog --title "Warning" \
    --msgbox "
WARNING: 32-Bit OS on 64-Bit Board!

Upgrade your distro to 64-bit to use your RAM.

Since you are only using a 32-bit OS, you cannot use more than 4 GB RAM for Minecraft. Abort and Upgrade." 13 50

    gamemem=2500
    gamememMIN=1500

  fi
else if (( $gamememMIN < 1024 )); then
  dialog --title "Warning" --yesno "\nWARNING: Either you have other things running, or your board is simply not good enough to run a Minecraft server. It is recommended you abort. ONLY install this on a dedicated system with no desktop environment or other applications running.\n\nWould you like to ABORT?" 14 50
  case $? in
  0)
   echo
   echo
   echo "Aborted."
   echo
   exit 1 ;;
  esac
fi
fi

dialog --title "Pinecraft Installer $pcver"  --yesno "Automatically load the server on boot?" 6 60
  case $? in
  0)
   cron=1
   ;;
  1)
   cron=0
   ;;
  esac

dialog --title "Information" \
--msgbox "
Detected Hardware:
$board

RAM to Allocate:
${gamememMIN##*( )}MB - ${gamemem##*( )}MB

Overclock To:
$oc_friendly

Server User:
$user

Server Version:
$flavor $mcver ($gamemode)" 20 50

if [[ ! $oc_volt == 0 ]]; then
  dialog --title "Confirmation"  --yesno "\nI will be modifying ${configfile} to overclock this ${board}. I am not responsible for damage to your system, and you do this at your own risk.\n\nContinue?" 12 50
  case $? in
  1)
   echo
   echo
   echo "Aborted."
   echo
   exit 1 ;;
  esac
fi

###############################################
# Finished Asking Questions: Begin Installation
###############################################

if [[ $upgrade == 1 ]] || [[ $replace == 1 ]]; then
  if [[ -e ${instdir}stop ]]; then
    dialog --infobox "Stopping server..." 3 22 ;
    su - $user -c "${instdir}stop" > /dev/null 2>&1
  fi
fi
if [[ $replace == 1 ]]; then
  dialog --infobox "Creating Backup in home folder..." 3 40 ;
  tar -czvf ${instdir}../pinecraft_backup-$(date -d "today" +"%Y-%m-%d-%H-%M").tar.gz $instdir > /dev/null 2>&1
  cd ${instdir}..
  dialog --infobox "Removing Old Install..." 3 27 ;
  rm -rf ${instdir}
  sleep 2
fi

if [[ $upgrade == 0 ]]; then
  mkdir $instdir
fi
cd $instdir

if [[ $upgrade == 1 ]]; then
  rm -rf src
fi
mkdir src && cd src

# The server version requires the supplemental download of the vanilla server
if [[ "$dlvanilla" = "1" ]]; then
  dialog --infobox "Downloading Vanilla..." 3 34 ;
  wget $vanilla -O ${instdir}server.jar > /dev/null 2>&1
fi

dialog --infobox "Downloading ${flavor}..." 3 34 ; sleep 1
if [[ $jarname != "" ]]; then
  wget $url -O minecraft.jar > /dev/null 2>&1
elif [[ $script != "" ]]; then
  wget $script -O minecraft.sh > /dev/null 2>&1
else
  # This should never happen. No URL or Script for selection
  echo
  echo
  echo "Died."
  echo
  exit 0
fi

dialog --infobox "Installing ${flavor}..." 3 34 ;
if [[ $url == $vanilla ]]; then
  # Vanilla doesn't need to be compiled, just copy the file
  cp minecraft.jar server.jar
elif [[ $flavor == "Cuberite" ]]; then
  sh minecraft.sh -m Release -t 1
  cuberiteresponse=$?
else
  java -Xmx500M -jar minecraft.jar $switches > /dev/null 2&>1
fi

if [[ $flavor == "Cuberite" ]]; then
  if [[ $cuberiteresponse != 0 ]]; then
    dialog --title "Error" \
      --msgbox "\nSadly, it appears compiling failed." 8 50
    echo
    echo
    echo "Failed."
    echo
    exit 0
  else
    mv cuberite/build-cuberite/Server/* $instdir
  fi
else
  # The installer also created or obtained the Minecraft server.jar file. Include it.
  if [[ -e ${instdir}src/server.jar ]]; then
    cp -f ${instdir}src/server.jar $instdir
  fi

  # Fabric and Forge use a libraries folder, so we'll keep that.
  if [[ -d ${instdir}src/libraries ]]; then
    # Move existing Libraries folder before replacing
    if [[ -e ${instdir}libraries ]]; then
      mv ${instdir}libraries ${instdir}libraries~backup_$(date +%Y-%m-%d_%H-%M-%S)
    fi
    mv ${instdir}src/libraries ${instdir}
    if [[ ! -e ${instdir}server.properties ]]; then
      cp ${SCRIPT_DIR}/assets/server.properties ${instdir}
    fi
  fi

  if [[ $flavor == "Forge" ]]; then
    # The forge installer removes itself and creates instead a minecraft.jar file
    # Use this instead to measure whether compile was successful
    jarname="minecraft.jar"
  fi

  jarfile=$(ls ${instdir}src/${jarname})
  if [[ $jarfile == "" ]]; then
    dialog --title "Error" \
      --msgbox "\nSadly, it appears compiling failed." 8 50
    echo
    echo
    echo "Failed."
    echo
    exit 0
  else
    cp $jarfile $instdir
    t=${jarfile#*-}
    version=$(basename $t .jar)
  fi
fi

###############################################
# Create the scripts
###############################################

dialog --infobox "Creating scripts..." 3 34 ; sleep 1

# Setup Aikars Flags
aikars="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

# Create the run script
echo '#!/bin/bash
user=$(whoami); if [[ $user != "'${user}'" ]]; then echo "Cannot run as ${user} - expecting '${user}'"; exit; fi
cd "$(dirname "$0")"' > ${instdir}server
if [[ $flavor == "Cuberite" ]]; then
  echo ${instdir}cuberite/Cuberite >> ${instdir}server
else
  # Forge requires its own unix_args be included
  if [[ $flavor == "Forge" ]]; then
    # Forge servers
    forge_args=$(ls ${instdir}libraries/net/minecraftforge/forge/*/unix_args.txt | head -n 1)
    forge_args="@${forge_args}"
    echo "exec java ${cli_args} -Xms${gamememMIN}M -Xmx${gamemem}M ${forge_args}" >> ${instdir}server
  else
    # Non-forge servers
    echo "exec java ${cli_args} -Xms${gamememMIN}M -Xmx${gamemem}M ${aikars} -jar `basename $jarfile` nogui" >> ${instdir}server
  fi
fi
chmod +x ${instdir}server

# Need to generate the config and EULA
# Note: Because the EULA is not yet accepted within eula.txt, the server will init and quit immediately.
if [[ $upgrade == 0 ]] || [[ ! -e ${instdir}server.properties ]]; then
  dialog --infobox "Initializing server..." 3 34 ; sleep 1
  su - $user -c ${instdir}server > /dev/null 2>&1
fi

# Accepting the EULA
if [[ $eula == "accepted" ]]; then
  echo "# https://account.mojang.com/documents/minecraft_eula ACCEPTED by user during installation
# $eula_stamp
eula=true" > ${instdir}eula.txt
fi

# Create the safe reboot script
echo '#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root" 2>&1
  exit 1
fi
su - $user -c "'${instdir}'stop"
echo
echo "Rebooting."
/sbin/reboot' > ${instdir}reboot
chmod +x ${instdir}reboot

# Create the safe stop script
echo '#!/bin/bash
user=$(whoami);
if [[ $user != "'${user}'" ]]; then
  if su - '$user' -c "/usr/bin/screen -list" | grep -q Pinecraft; then
    printf "Stopping Minecraft Server. This will take time."
    su - '$user' -c "screen -S Pinecraft -p 0 -X stuff \"stop^M\""
    running=1
  fi
  while [[ $running == 1 ]]; do
    if ! su - '$user' -c "/usr/bin/screen -list" | grep -q Pinecraft; then
      running=0
    fi
    sleep 3
    printf "."
  done
else
  if /usr/bin/screen -list | grep -q Pinecraft; then
    printf "Stopping Minecraft Server. This will take time."
    screen -S Pinecraft -p 0 -X stuff "stop^M"
    running=1
  fi
  while [[ $running == 1 ]]; do
    if ! /usr/bin/screen -list | grep -q Pinecraft; then
      running=0
    fi
    sleep 3
    printf "."
  done
fi
echo
echo "Done. Minecraft has been stopped safely."' > ${instdir}stop
chmod a+x ${instdir}stop

# Create the service
echo '#/bin/bash
set -e

### BEGIN INIT INFO
# Provides:       pinecraft
# Required-Start: $remote_fs $network
# Required-Stop:  $remote_fs
# Default-Stop:   0 1 6
# Short-Description: Minecraft server powered by Pinecraft Installer
### END INIT INFO

case "$1" in

stop)
      '${instdir}'stop
    ;;

status)
      user=$(whoami); if [ $user != "'${user}'" ]; then echo "Cannot run as ${user} - expecting '${user}'"; exit; fi
      if screen -ls | grep -q Pinecraft; then
        echo 1
      else
        echo 0
      fi
    ;;

*)

    echo "usage: $0 <stop|status>" >&2

    exit 1
esac
' > /etc/init.d/pinecraft
chmod a+x /etc/init.d/pinecraft

# Remove old symlinks
if [[ -s /etc/rc0.d/K01stop-pinecraft ]]; then
  rm -f /etc/rc0.d/K01stop-pinecraft
fi
if [[ -s /etc/rc6.d/K01stop-pinecraft ]]; then
  rm -f /etc/rc6.d/K01stop-pinecraft
fi
# Make the stop command run automatically at shutdown
ln -s ${instdir}stop /etc/rc0.d/K01stop-pinecraft
# Make the stop command run automatically at reboot
ln -s ${instdir}stop /etc/rc6.d/K01stop-pinecraft

###############################################
# /Create the scripts
###############################################

###############################################
# Create config folders
###############################################

  if [[ ! -d /etc/pinecraft/pid/ ]]; then
    mkdir -p /etc/pinecraft/pid
  fi

  chown -R $user:$user /etc/pinecraft/

###############################################
# /Create config folders
###############################################

###############################################
# Tweak Server Configs
###############################################

if [[ -e ${instdir}server.properties ]]; then

  dialog --infobox "Applying config..." 3 34 ; sleep 1
  # These settings are my own defaults, so only do these during first install (not upgrade)
  # Will not replace user-configured changes in the server.properties
  if [[ $upgrade == 0 ]]; then

    # Enable Query
      # Change the value if it exists
      /bin/sed -i '/enable-query=/c\enable-query=true' ${instdir}server.properties
      # Add it if it doesn't exist
      if ! grep -q "enable-query=" ${instdir}server.properties; then
        echo "enable-query=true" >> ${instdir}server.properties
      fi

    # Set game difficulty to Normal (default is Easy, but we want at least SOME challenge)
      # Change the value if it exists
      /bin/sed -i '/difficulty=/c\difficulty=normal' ${instdir}server.properties
      # Add it if it doesn't exist
      if ! grep -q "difficulty=" ${instdir}server.properties; then
        echo "difficulty=normal" >> ${instdir}server.properties
      fi

    # Set the view distance to something the Raspberry Pi can handle quite well
      # Change the value if it exists
      /bin/sed -i '/view-distance=/c\view-distance=7' ${instdir}server.properties
      # Add it if it doesn't exist
      if ! grep -q "view-distance=" ${instdir}server.properties; then
        echo "view-distance=16" >> ${instdir}server.properties
      fi

    # Level Seed
      # Change the value if it exists
      /bin/sed -i "/level-seed=/c\level-seed=${seed}" ${instdir}server.properties
      # Add it if it doesn't exist
      if ! grep -q "level-seed=" ${instdir}server.properties; then
        echo "level-seed=${seed}" >> ${instdir}server.properties
      fi

  fi

  # These ones, however, are selected by the user, so we'll make these changes even if already installed
    # Game Mode (User Selected During Install)
      # Change the value if it exists
      /bin/sed -i "/gamemode=/c\gamemode=${gamemode}" ${instdir}server.properties
      # Add it if it doesn't exist
      if ! grep -q "gamemode=" ${instdir}server.properties; then
        echo "gamemode=${gamemode}" >> ${instdir}server.properties
      fi
fi

# Set ownership to the user
dialog --infobox "Setting ownership..." 3 24
chown -R $user:$user $instdir

###############################################
# Install cronjob to auto-start server on boot
###############################################

# Set the cron tmp file path
cron_tmp_file="/tmp/cron.tmp"

# Dump current crontab to tmp file, if the crontab doesn't exist it will be empty
crontab -u "$user" -l > "$cron_tmp_file" 2> /dev/null

# Flag to check whether the crontab needs to be updated
cron_needs_updating=false

if [[ "$cron" == "1" ]]; then
  # Remove any existing Pinecraft server-related cron jobs
  if grep -q "${instdir}server" "$cron_tmp_file"; then
    /bin/sed -i~ "\~${instdir}server~d" "$cron_tmp_file"
    cron_needs_updating=true
  fi

  # Add server to auto-load at boot if it doesn't already exist in crontab
  if ! grep -q "minecraft/server" "$cron_tmp_file"; then
    dialog --infobox "Enabling auto-run..." 3 34
    sleep 1
    echo "@reboot /usr/bin/screen -dmS Pinecraft ${instdir}server > /dev/null 2>&1" >> "$cron_tmp_file"
    cron_needs_updating=true
  fi
else
  # Remove the Pinecraft server-related cron job if it exists because auto-run is not requested
  if grep -q "${instdir}server" "$cron_tmp_file"; then
    /bin/sed -i~ "\~${instdir}server~d" "$cron_tmp_file"
    cron_needs_updating=true
  fi
fi

# Import revised crontab if any changes have been made
if [[ "$cron_needs_updating" == true ]]; then
  crontab -u "$user" "$cron_tmp_file"
fi

# Remove the temporary cron file
rm -f "$cron_tmp_file"

###############################################
# /Install cronjob to auto-start server on boot
###############################################

###############################################
# Run the server now
###############################################

  dialog --infobox "Starting the server..." 3 26 ;
  su - $user -c "/usr/bin/screen -dmS Pinecraft ${instdir}server"

###############################################
# /Run the server now
###############################################

# Check if flavor is Forge and mods directory exists to determine initialization success
if [[ $flavor == "Forge" ]]; then
  mods_dir="${instdir}mods"
  server_props="${instdir}server.properties"

  if [[ ! -d $mods_dir ]]; then
    # Initialization failed since 'mods' folder was not found. Take corrective measures.
    if [[ -e $server_props ]]; then
      # Remove the server.properties file to avoid misrepresenting success
      rm "$server_props" || { echo "Error: Failed to remove $server_props"; exit 1; }
    fi

    # Display a warning dialog to inform about initialization issues
    dialog --title "Warning" \
      --msgbox "\nForge installation detected, but is not initializing correctly. Modifications may be required for proper functionality." 9 50
  else
    # Initialization was successful. Display success message.
    dialog --title "Success" \
      --msgbox "\nForge Minecraft server installed and initialized successfully." 8 50
  fi
else
  # Handle the installation of other flavors and check for existence of server.properties file
  if [[ -e $server_props ]]; then
    # Confirm success of installation for flavors other than Forge
    dialog --title "Success" \
      --msgbox "\n$flavor Minecraft server installed successfully." 8 50
  else
    # Warn about potential issues for flavors other than Forge
    dialog --title "Warning" \
      --msgbox "\n$flavor Minecraft server appears to have installed, but is not initializing correctly. It is unlikely to work until this is resolved." 9 50
  fi
fi

# Clear the terminal and present final information
clear
echo "Installation complete."
echo
echo "Minecraft server is now running on $ip."
echo
echo "Remember: World generation can take a few minutes. Be patient."
echo
