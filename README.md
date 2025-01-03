# node-tools

Some tools built for easier management of highly-available RPC nodes

`check_rpc_nodes.sh` will check whether any node from the list is in catching_up state or not.

`block_height_compare.sh` checks whether endpoint1 is within the acceptable range of other nodes on the network. If it's behind by more than 2 blocks, it will restart the process.
