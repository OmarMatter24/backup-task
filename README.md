# backup-task
#!/bin/bash

# ========== Configurable Variables ==========
SOURCE_DIR="/etc"              # Directory to back up
BACKUP_DIR="/opt/backups/system"  # Where to store backups
LOG_DIR="/var/log/system-backup"  # Where to store logs
RETENTION_DAYS=7                  # Number of backups to keep
LOG_RETENTION=5                   # Number of logs to retain
EMAIL_TO="mohamedroute77@gmail.com"      # Email to alert
HOSTNAME=$(hostname)

# Create directories if not exist
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Date formats
TODAY=$(date +%F)
TIME=$(date +%F_%H-%M-%S)
LOG_FILE="$LOG_DIR/backup_$TIME.log"
BACKUP_FILE="$BACKUP_DIR/backup_${TODAY}.tar.gz"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "=== Backup Started at $TIME ==="

# ========== Backup Process ==========
if tar -czf "$BACKUP_FILE" "$SOURCE_DIR"; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed for directory: $SOURCE_DIR"
    echo "Sending failure email alert..."
    echo "Backup failed on $HOSTNAME at $TIME. See log: $LOG_FILE" | \
        mail -s "[Backup Failed] $HOSTNAME - $TODAY" "$EMAIL_TO"
    exit 1
fi

# ========== Backup Retention ==========
echo "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

# ========== Log Rotation ==========
echo "Rotating logs, keeping last $LOG_RETENTION logs..."
cd "$LOG_DIR" || exit
ls -1tr backup_*.log | head -n -$LOG_RETENTION | xargs -r rm -f

echo "=== Backup Completed Successfully ==="
------------------------------------------------------------------------------------

1) ls -lh /var/log/system-backup/

2)tail -n 20 /var/log/system-backup/backup_*.log

3)ls -lh /opt/backups/system/

