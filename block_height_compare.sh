#!/bin/bash

get_block_height() {
    endpoint=$1
    block_height=$(curl -sk "$endpoint" | jq -r '.result.sync_info.latest_block_height')
    echo "$block_height"
}

get_block_time() {
    endpoint=$1
    block_time=$(curl -sk "$endpoint" | jq -r '.result.sync_info.latest_block_time')
    echo "$block_time"
}

check_catching_up() {
    endpoint=$1
    catching_up=$(curl -sk "$endpoint" | jq -r '.result.sync_info.catching_up')
    echo "$catching_up"
}

check_stalled_sync() {
    initial_height=$(get_block_height "$endpoint1")
    catching_up=$(check_catching_up "$endpoint1")
    
    if [ "$catching_up" == "true" ]; then
        echo "Node is in catching up state. Checking for stalled sync..."
        sleep 60  # Wait 1 minute
        current_height=$(get_block_height "$endpoint1")
        
        if [ "$initial_height" == "$current_height" ]; then
            echo "Node is stalled. Block height hasn't changed in 1 minute. Restarting service."
            systemctl restart akash-node
            exit 0
        fi
    fi
}

check_block_time() {
    local_time=$(date -u +"%Y-%m-%dT%H:%M:%S")
    block_time=$(get_block_time "$endpoint1")
    
    # Convert times to seconds since epoch
    local_seconds=$(date -d "$local_time" +%s)
    block_seconds=$(date -d "$block_time" +%s)
    
    # Calculate time difference
    time_diff=$((local_seconds - block_seconds))
    
    if [ "$time_diff" -gt 60 ]; then
        echo "Node is behind current time by ${time_diff} seconds. Restarting service."
        systemctl restart akash-node
        exit 0
    fi
}

endpoint1="http://127.0.0.1:26657/status"

# Check for stalled sync first
check_stalled_sync

# Check if block time is within acceptable range
check_block_time

echo "Node status is healthy"
echo "Block Height: $(get_block_height "$endpoint1")"
echo "Block Time: $(get_block_time "$endpoint1")"
echo "Current Time (UTC): $(date -u +"%Y-%m-%dT%H:%M:%S")"
