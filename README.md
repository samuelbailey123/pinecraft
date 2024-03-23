## Minecraft Java Server Installer for Raspberry Pi, PINE64 and Other SBCs.

This installer simplifies the installation and setup of a Minecraft Java Server.

If you have already installed this, running it again will allow you to upgrade.

## About Pinecraft Installer

The installer will setup a "Normal" difficulty server and allow you to select between a Survival world complete with mobs, nether and more, or a Creative world to hone your skills as a master builder.

The installer attempts to detect things like how much RAM you have (and available), and adjusts the server settings based on what it finds.

# MINECRAFT VERSION

- Minecraft Version 1.20.4 is the only version i support because it's what I play.

# Base OS (Distro)

**Do not use Pinecraft Installer on a Base OS that contains a desktop environment, or any other running applications.** Pinecraft Installer is intended to setup a _dedicated_ Minecraft Java server, and the device should be used for nothing else.

**NEVER install Pinecraft on your desktop system. This is a dedicated server. That means once you install it, the system is no longer useable for anything else.**

## Supported Base OS

**Raspberry Pi 4 8 GB**

- Download Ubuntu Server 22.04.3 64-Bit: https://cdimage.ubuntu.com/releases/22.04.3/release/ubuntu-22.04.3-preinstalled-server-arm64+raspi.img.xz
- Default Login/Password: ubuntu/ubuntu

**Khadas VIM4 8 GB**

- Boot into OOWOW (hold the middle button and tap the button nearest the USB port, continue holding the middle button).
- Enter the downloads menu and choose Refresh Images List.
- Install vim4-ubuntu-22.04-**server**-linux-5.4-fenix-... (make absolutely certain you have selected the **server** version).
- Default Login/Password: khadas/khadas

## Compatibility Tests

**Pass**

- Raspberry Pi 4 8 GB (Fast SD Card can accommodate 2-3 players no problem, add external fast USB 3.0 storage for 10+ players)
- Khadas VIM4 (Excellent performance for 10+ players out of the box)

**Fail**

- Radxa ROCK 3A 8 GB (Worldgen is unusably slow)

# Server Versions

**Vanilla** Fast Build Time

Vanilla is the official Mojang Minecraft server release. It does not allow mods, and is not as well optimized for SBC use, but will run great on a Raspberry Pi 4 with 4GB RAM or higher. [More Info](https://minecraft.net

I only support vanilla at this time because I don't want to support anything else.

# Game Modes

**Survival**

Players must collect resources, build structures, battle mobs, eat, and explore the world in an effort to thrive and survive.

**Creative**

Creative mode strips away the survival aspects of Minecraft and allows players to easily create and destroy structures and mechanisms with the inclusion of an infinite use of blocks and flying.

# Hardware Requirements

- A vanilla server OS based on Debian (such as Raspberry Pi OS Lite) with nothing else running and no desktop environment.
- If your board has more than 4 GB RAM, you must use a 64-Bit OS to utilize it effectively. Running a 32-bit OS will result in less RAM dedicated to your Minecraft Server.
- Minimum 4 GB RAM.
- GOOD Power Supply.
- Reliable Storage Media (Kingston Endurance microSD or UASP-enabled USB 3 SSD).
- Ethernet connection to network (don't use Wi-Fi).

# Plugin Support

For any of the server versions which support plugins (see "Server Versions" above) simply place the plugin ZIP file in ~/minecraft/plugins and then run `~/minecraft/restart`

Remember, adding plugins can have a negative impact on your server performance. Some plugins may also introduce bugs, glitches or other issues. Be selective about which plugins you add to your server.

# Level Seeds

During installation, you can choose from one of our provided level seeds, or use your own.

**Category5 TV RPi Server** [via Category5 Technology TV](https://cat5.tv/minecraft)

Complete with the mystical floating tree at spawn! Head North West to -396 ~ 148 to [find the town nether portal](https://youtu.be/-8-7fQmhn2k?t=824), which takes only a little work to get up and running.

**Jeff's Tutorial World** [via Category5 Technology TV](https://cat5.tv/minecraft)

The world used in Jeff's tutorials such as [Easy XP and Loot with Minecraft Zombie Grinder XP Farm NO REDSTONE](https://youtu.be/5b570XG0pf4) and [Trading Hack: Giving Villagers a Job in Minecraft - Villager Professions](https://youtu.be/NJ4aaOQHqhM)

**All Biome World** [via Reddit/Plebiain](https://www.reddit.com/r/minecraftseeds/comments/h84n1j/spawn_on_a_mushroom_island_in_a_small_ocean/)

This seed provides all biomes within easy reach of one another. It also includes many structures, making it an exciting seed to explore.

**Paradise Valley** [via Reddit/SpaceBoiArt](https://www.reddit.com/r/minecraftseeds/comments/ia3dog/created_a_new_world_and_spawned_in_this_awesome/)

An ideal seed for colossal builds. The level plains of Paradise Valley are surrounded by mountains, with resource-rich forests only a short journey from spawn.

# Note About Backups

Please consider automating a backup of your world. You can first stop the server with the provided `stop` script, then run your backup, and then restart your server with the provided `server` script.

# Usage

Run the installer immediately following a fresh reboot (to avoid having residual apps taking up RAM thereby resulting in less RAM allocated to your game server).

The command is simple:

`sudo make create`

To reboot **do not** use traditional Linux commands. You must use:
`sudo ~/minecraft/reboot`

This is to save the world in a valid and safe manner.

# Post-Install

### Commands

If you opted to have Pinecraft load your Minecraft server at boot, your Minecraft server will be running in a screen session.

**Important Note:** All commands must be run as the user you originally specified in Pinecraft Installer (do not run as _root_, for example).

`screen -ls` will reveal running screen sessions. There should be one called _Pinecraft_.

`screen -r Pinecraft` re-attaches to the Pinecraft screen session (the Minecraft console) where you can enter console commands directly.

From within the screen session, detach (exit) by pressing `CTRL-A` followed by `D`. This will detach the screen session but leave your Minecaft server running.

### Scripts

`~/minecraft/stop`
Safely stop your Minecraft server. **Never reboot your system or power off using traditional Linux commands unless you have first run this script and allowed it to complete.** Failure to safely stop your Minecraft server will result in lost blocks and potentially world corruption. Running this script is the same as entering the `stop` command within the Minecraft console.

`~/minecraft/server`
Start the Minecraft server. This script is automatically run upon boot if you selected this feature. Of course, if you specified for Pinecraft to automatically load your Minecraft server on boot, you generally won't need this script.

`sudo ~/minecraft/reboot`
**Note:** This is the only of the scripts where sudo is required. When you need to reboot your Minecraft server, you must do so safely, otherwise all blocks that are stored in RAM will be lost (could be a full day's worth). Run this script to shutdown the Minecraft server software, store all blocks, and reboot the server. Note: It can easily take 15-20 minutes to stop the Minecraft server. Don't abort once you run this script. It is working hard to save all the blocks for your world and if you stop it or force a reboot, you will lose blocks.

# Networking

Your Minecraft server runs on port 25565. If you'd like others to be able to join your server, forward that port to your Minecraft server in your firewall.

# Log Files

### ~/minecraft/logs/latest.log

The current Minecraft Server log file. You can run `tail -f ~/minecraft/logs/latest.log` on your Minecraft Server to see what's happening. Logs are rotated and gzipped by date.

### Server gets killed by Linux

Try `dmesg -T| grep -E -i -B100 'killed process'` after this happens to see why Linux killed the process. It is most likely you are running other applications on your system (which is a big no-no) and have run out of resources. You should only run this on a completely headless SBC, with no desktop environment, and nothing else running. You can adjust the amount of RAM allocated by editing the `server` script in ~/minecraft

# Post-Install Configuration

Give your Minecraft server a try before you start changing the config. It's very possible to break things if you modify the config, so it's a good start to test your server first, and then just tweak what's needed / desired.

You'll find your config file here: ~/minecraft/server.properties

Mojang Documentation: https://minecraft.gamepedia.com/Server.properties#Java_Edition_3

# Frequently Asked Questions

Remember, Pinecraft Installer installs a Minecraft server like any other. Our goal is to make it easy for you to get up and running with an efficient, high-performance server, but we don't rework how the resulting server works in any way. Therefore, the official Minecraft docs are the perfect place to get help with your server configuration.

That said, we get some questions regularly, and we're here to help if we can, so we'll record them here.

**First, here are some helpful links:**

Modify server.properties, the main config file for your server's settings
https://minecraft.gamepedia.com/Server.properties#Java_Edition_3

**And here are some FAQ's:**

### How do I become admin? /op says I don't have permission.

After connecting to your server as the user you want to make admin, look at your `~/minecraft/logs/latest.log` file and find the UUID for that user.

Edit `~/minecraft/ops.json` as follows:

```
[
  {
    "uuid": "UUID",
    "name": "USERNAME",
    "level": 4
  }
]
```

Replace UUID with your UUID, and USERNAME with the actual username.

Here is a helpful tool I created to assist: https://category5.tv/tools/minecraft/uuid/

Then, restart your Pinecraft server with `~/minecraft/reboot`

When your server comes back online, that user will be admin, and can now use the /op command to create other admins.

### How do I re-generate my world?

To completely destroy your world and regenerate it, you simply need to remove the files.

Step 1: Stop your Minecraft server. `~/minecraft/stop`

Step 2: Remove the world (this cannot be undone): `rm -rf ~/minecraft/world*`

Step 3: Restart your Minecraft server by whichever means you prefer (E.G., reboot your server with `sudo ~/minecraft/reboot`) - Remember, the first time the server loads, it will generate a new world. Give it 10 minutes or so before you attempt to connect.
