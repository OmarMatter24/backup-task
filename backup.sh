#!/bin/bash

SOURCE_DIR="/var/www"           # Directory to back up
BACKUP_DIR="/var/backups"       # Where backups are stored
LOG_DIR="/var/log/backup"       # Where logs are stored
RETENTION_DAYS=7                # Number of backups to keep
LOG_RETENTION=5                 # Number of log files to keep
EMAIL="omarhanymatter@gmail.com"       # Email for error alerts

DATE=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.tar.gz"
LOG_FILE="${LOG_DIR}/backup_${DATE}.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

{
    echo "===== BACKUP STARTED at $(date) ====="
    echo "Backing up: $SOURCE_DIR"
    echo "Destination: $BACKUP_FILE"

    if tar -czf "$BACKUP_FILE" "$SOURCE_DIR" ; then
        echo "Backup completed successfully."
    else
        echo "ERROR: Backup failed!"
        echo "Sending email alert to $EMAIL..."
        echo "Backup failed on $(hostname) at $(date)" | mail -s "Backup FAILED on $(hostname)" "$EMAIL"
        exit 1
    fi

    echo "Removing backups older than $RETENTION_DAYS days..."
    find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

    echo "Backup cleanup complete."

   
    echo "Rotating logs (keeping last $LOG_RETENTION)..."
    ls -1t "$LOG_DIR"/backup_*.log 2>/dev/null | tail -n +$((LOG_RETENTION+1)) | xargs -r rm -f

    echo "===== BACKUP FINISHED at $(date) ====="
} > "$LOG_FILE" 2>&1
