#!/bin/bash
# System Backup Manager v2.1
LOGFILE="/var/log/backup_mgr.log"

echo "[$(date)] Starting backup sequence..." > $LOGFILE

# Check for custom environment hooks 
HOOK_SCRIPT="/var/scripts/env_setup.sh"

if [ -f "$HOOK_SCRIPT" ]; then
    echo "[$(date)] Found custom hook: $HOOK_SCRIPT. Running setup..." >> $LOGFILE
    source "$HOOK_SCRIPT"
else
    echo "[$(date)] No custom hooks found. Using default ENV." >> $LOGFILE
fi

# Backup the web directory
TIMESTAMP=$(date +%d_%b_%Y)
ARCHIVE_NAME=web_backup_$TIMESTAMP.tar.gz
echo "[$(date)] Creating archive $ARCHIVE_NAME"
tar -czf /var/backups/$ARCHIVE_NAME -C /var/www html 2>> $LOGFILE

echo "[$(date)] Backup completed successfully." >> $LOGFILE
