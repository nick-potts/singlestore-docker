#!/bin/bash

# Create data directory if it doesn't exist
mkdir -p /data
chown -R memsql:memsql /data

echo "Configuring SingleStore nodes to use /data directory..."

# Stop all nodes first (required per documentation)
echo "Stopping all nodes..."
sdb-admin stop-node --all --yes

# Get full node IDs from JSON output and update their configuration
sdb-admin list-nodes --json | jq -r '.nodes[].memsqlId' | while read -r node_id; do
    if [ ! -z "$node_id" ]; then
        echo "Updating data directory for node: $node_id"
        sdb-admin update-config --key datadir --value /data --memsql-id "$node_id" --yes
    fi
done

echo "Data directory configuration complete"