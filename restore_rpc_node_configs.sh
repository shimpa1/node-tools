## EXAMPLE USES:
## List available backups for a server:
## ./restore_rpc_nodes.sh list 10.4.8.201

## Restore a specific backup:
## ./restore_rpc_nodes.sh restore 10.4.8.201 20250106_132001

## Restore the most recent backup:
## ./restore_rpc_nodes.sh restore-latest 10.4.8.201

#!/bin/bash

# Configuration - files to restore
FILES_TO_RESTORE=(
    "/root/.akash/config/config.toml"
    "/root/.akash/config/app.toml"
    "/root/.akash/config/priv_validator_key.json"
    "/root/.akash/config/node_key.json"
    "/root/.akash/data/priv_validator_state.json"
    "/root/block_height_compare.sh"
    "/etc/environment"
)

# Function to list available backups for a server
list_backups() {
    local server=$1
    local backup_dir="./backups/$server"
    
    if [ ! -d "$backup_dir" ]; then
        echo "No backups found for server $server"
        return 1
    fi
    
    echo "Available backups for $server:"
    ls -1 "$backup_dir"
}

# Function to restore files to a single server
restore_server() {
    local server=$1
    local timestamp=$2
    local backup_dir="./backups/$server/$timestamp"
    
    if [ ! -d "$backup_dir" ]; then
        echo "Error: Backup directory not found: $backup_dir"
        return 1
    fi
    
    echo "Starting restoration for $server from backup $timestamp"
    echo "=============================="
    
    # Restore each file
    for file in "${FILES_TO_RESTORE[@]}"; do
        local backup_file="$backup_dir$file"
        
        if [ ! -f "$backup_file" ]; then
            echo "✗ Backup file not found: $backup_file"
            continue
        fi
        
        # Create remote directory structure
        ssh -o StrictHostKeyChecking=no "root@$server" "mkdir -p $(dirname "$file")" 2>/dev/null
        
        # Perform restoration using rsync
        if rsync -avz -e "ssh -o StrictHostKeyChecking=no" "$backup_file" "root@$server:$file" 2>/dev/null; then
            echo "✓ Successfully restored $file to $server"
        else
            echo "✗ Failed to restore $file to $server"
        fi
    done
    
    echo "Completed restoration for $server"
    echo "----------------------------"
}

# Display usage information
usage() {
    echo "Usage:"
    echo "  $0 list <server>                    # List available backups for a server"
    echo "  $0 restore <server> <timestamp>     # Restore specific backup to server"
    echo "  $0 restore-latest <server>          # Restore most recent backup to server"
    echo
    echo "Examples:"
    echo "  $0 list 10.4.8.201"
    echo "  $0 restore 10.4.8.201 20250106_132001"
    echo "  $0 restore-latest 10.4.8.201"
}

# Main execution
case "$1" in
    "list")
        if [ -z "$2" ]; then
            echo "Error: Server not specified"
            usage
            exit 1
        fi
        list_backups "$2"
        ;;
        
    "restore")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Server or timestamp not specified"
            usage
            exit 1
        fi
        restore_server "$2" "$3"
        ;;
        
    "restore-latest")
        if [ -z "$2" ]; then
            echo "Error: Server not specified"
            usage
            exit 1
        fi
        latest=$(ls -1 "./backups/$2" | sort -r | head -n1)
        if [ -z "$latest" ]; then
            echo "No backups found for server $2"
            exit 1
        fi
        echo "Using latest backup: $latest"
        restore_server "$2" "$latest"
        ;;
        
    *)
        usage
        exit 1
        ;;
esac
