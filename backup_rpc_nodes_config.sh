#!/bin/bash

# Configuration
BACKUP_DIR="$(pwd)/backups"  # Using current directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILES_TO_BACKUP=(
    "/root/.akash/config/config.toml"
    "/root/.akash/config/app.toml"
    "/root/.akash/config/priv_validator_key.json"
    "/root/.akash/data/priv_validator_state.json"
    "/root/block_height_compare.sh"
    "/etc/environment"
)

# Create backup directory if it doesn't exist
if ! mkdir -p "$BACKUP_DIR"; then
    echo "Error: Cannot create backup directory $BACKUP_DIR"
    exit 1
fi

# Function to backup files from a single server
backup_server() {
    local server=$1
    local server_backup_dir="$BACKUP_DIR/$server/$TIMESTAMP"
    
    echo "Starting backup for $server..."
    
    # Create server-specific backup directory
    if ! mkdir -p "$server_backup_dir"; then
        echo "Error: Cannot create server backup directory for $server"
        return 1
    fi
    
    # Backup each file
    for file in "${FILES_TO_BACKUP[@]}"; do
        # Create directory structure
        local dir_path="$server_backup_dir$(dirname "$file")"
        if ! mkdir -p "$dir_path"; then
            echo "Error: Cannot create directory structure $dir_path"
            continue
        fi
        
        # Perform backup using rsync
        if rsync -avz -e "ssh -o StrictHostKeyChecking=no" "root@$server:$file" "$server_backup_dir$file" 2>/dev/null; then
            echo "✓ Successfully backed up $file from $server"
        else
            echo "✗ Failed to backup $file from $server"
        fi
    done
    
    echo "Completed backup for $server"
    echo "----------------------------"
}

# Main execution
echo "Starting backup process at $TIMESTAMP"
echo "=============================="

# If no arguments provided, read from server_list.txt
if [ $# -eq 0 ]; then
    if [ ! -f "server_list.txt" ]; then
        echo "Error: server_list.txt not found and no servers specified as arguments"
        exit 1
    fi
    while read -r server || [[ -n "$server" ]]; do
        # Skip empty lines and comments
        [[ -z "$server" || "$server" =~ ^[[:space:]]*# ]] && continue
        backup_server "$server"
    done < "server_list.txt"
else
    # Use servers provided as arguments
    for server in "$@"; do
        backup_server "$server"
    done
fi

echo "Backup process completed"
echo "Backup location: $BACKUP_DIR"
