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
memsqlctl list-nodes --json | jq -r '.nodes[] | select(.role == "Leaf") | .memsqlId' | while read -r node_id; do
    if [ ! -z "$node_id" ]; then
        echo "Updating data directory for leaf node: $node_id"
        # Stop the node
        memsqlctl stop-node --memsql-id "$node_id" --yes
        # Update the configuration
        memsqlctl update-config --memsql-id "$node_id" --key datadir --value /data --yes
        echo "Configuration updated for node $node_id"
    fi
done

# Show final node configuration
echo "Final node configuration:"
memsqlctl list-nodes --json | jq '.nodes[] | {memsqlId: .memsqlId, role: .role, datadir: .datadir}'

echo "Data directory configuration complete"