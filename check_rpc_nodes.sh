#!/bin/bash

get_node_status() {
   ip=$1
   endpoint="http://$ip:26657/status"
   
   response=$(curl -sk "$endpoint")
   block_height=$(echo "$response" | jq -r '.result.sync_info.latest_block_height')
   catching_up=$(echo "$response" | jq -r '.result.sync_info.catching_up')
   
   echo "Node $ip:"
   echo "  Block Height: $block_height"
   echo "  Catching Up: $catching_up"
   echo "-------------------"
}

# Check all nodes in range
for i in {201..216}; do
   get_node_status "10.4.8.$i"
done
