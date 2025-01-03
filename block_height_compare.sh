#!/bin/bash
get_block_height() {
    endpoint=$1
    block_height=$(curl -sk "$endpoint" | jq -r '.result.sync_info.latest_block_height')
    echo "$block_height"
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
            echo "Node is stalled. Block height hasn't changed in 5 minutes. Restarting service."
            systemctl restart akash-node
            exit 0
        fi
    fi
}

endpoint1="http://127.0.0.1:26657/status"
endpoint2="https://rpc.akash.forbole.com:443/status"
endpoint3="https://rpc-akash.ecostake.com:443/status"
endpoint4="https://akash-rpc.polkachu.com:443/status"
endpoint5="https://akash.c29r3.xyz:443/rpc/status"
endpoint6="https://rpc.akashnet.net:443/status"

# Check for stalled sync first
check_stalled_sync

height1=$(get_block_height "$endpoint1")
height2=$(get_block_height "$endpoint2")
height3=$(get_block_height "$endpoint3")
height4=$(get_block_height "$endpoint4")
height5=$(get_block_height "$endpoint5")
height6=$(get_block_height "$endpoint6")

catching_up=$(check_catching_up "$endpoint1")

heights=($height2 $height3 $height4 $height5 $height6)
for height in "${heights[@]}"; do
    difference=$((height1 - height))
    if [ "$difference" -gt 2 ] || [ "$difference" -lt -2 ]; then
        if [ "$catching_up" == "false" ]; then
            echo "Node is not catching up and block height difference is more than 2. Restarting service."
            systemctl restart akash-node
            exit 0
        fi
    fi
done

echo "Block heights are within acceptable range."
echo "Block Height - Your Node: $height1"
echo "Other Endpoints Heights: ${heights[*]}"
