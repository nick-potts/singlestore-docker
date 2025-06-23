#!/bin/bash

# Create data directory if it doesn't exist
mkdir -p /data
chown -R memsql:memsql /data

echo "Configuring SingleStore nodes to use /data directory..."

# First, let's see what nodes we have
echo "Listing all nodes:"
memsqlctl list-nodes --json | jq '.'

# List all memsql nodes managed by memsqlctl and process only Leaf nodes
echo "Finding and configuring leaf nodes..."

# Get all nodes and check their ports to identify leaf nodes (port 3307)
memsqlctl list-nodes --json | jq -c '.nodes[]' | while read -r node_info; do
    node_id=$(echo "$node_info" | jq -r '.memsqlId')
    node_port=$(echo "$node_info" | jq -r '.port')
    node_role=$(echo "$node_info" | jq -r '.role')
    
    # Only process nodes on port 3307 (leaf nodes)
    if [ "$node_port" = "3307" ]; then
        echo "Found leaf node on port $node_port with ID: $node_id"
        echo "Updating data directory for leaf node: $node_id"
        
        # Stop the node
        memsqlctl stop-node --memsql-id "$node_id" --yes
        
        # Update the configuration
        memsqlctl update-config --memsql-id "$node_id" --key datadir --value /data --yes
        echo "Configuration updated for node $node_id"
    else
        echo "Skipping node on port $node_port (role: $node_role)"
    fi
done

# Show final node configuration
echo "Final node configuration:"
memsqlctl list-nodes --json | jq '.nodes[] | {memsqlId: .memsqlId, role: .role, port: .port, datadir: .datadir}'

echo "Data directory configuration complete"