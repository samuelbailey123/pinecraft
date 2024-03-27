#!/bin/bash

# Define log file
LOG_FILE="/var/log/minecraft_backup.log"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Stop the Minecraft server
log_message "Stopping the Minecraft server..."
sudo /home/samuelbailey/minecraft/stop >> "$LOG_FILE" 2>&1

# Define the destination directory
DEST_DIR="/media/samuelbailey/SANDISK/minecraft_$(date +'%m-%d-%Y_%H-%M-%S')"

# Create the destination directory
log_message "Creating destination directory: $DEST_DIR"
mkdir -p "$DEST_DIR" >> "$LOG_FILE" 2>&1

# Copy the entire Minecraft directory to the destination
log_message "Copying Minecraft directory to destination..."
cp -r /home/samuelbailey/minecraft "$DEST_DIR" >> "$LOG_FILE" 2>&1

# Restart the Minecraft server
log_message "Restarting the Minecraft server..."
sudo -u samuelbailey /usr/bin/screen -dmS Pinecraft /home/samuelbailey/minecraft/server >> "$LOG_FILE" 2>&1

log_message "Backup completed successfully."
