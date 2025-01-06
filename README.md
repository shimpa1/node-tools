# node-tools

Some tools built for easier management of highly-available RPC nodes

`check_rpc_nodes.sh` will check whether any node from the list is in catching_up state or not.

`block_height_compare.sh` checks whether endpoint1 is within the acceptable time discrepancy. If it's behind by more than 60 seconds, it will restart the node service.

`backup_rpc_nodes_config.sh` will create backups of most critical files of a RPC node. The list of servers needs to be in server_list.txt, within the same directory where this script is.

`restore_rpc_node_configs.sh` will restore the backups created by `backup_rpc_nodes_config.sh`. Check usage in the file contents.

