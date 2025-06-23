#!/bin/bash

# Create data directory if it doesn't exist
mkdir -p /data
chown -R memsql:memsql /data

echo "Configuring SingleStore nodes to use /data directory..."

# Get list of all nodes and update their data directory
# Using awk since nodes aren't started yet
sdb-admin list-nodes | grep -E "Master|Leaf|Aggregator" | awk '{print $1}' | while read -r node_id; do
    if [ ! -z "$node_id" ] && [ "$node_id" != "|" ]; then
        echo "Updating data directory for node: $node_id"
        sdb-admin update-config --key datadir --value /data --memsql-id "$node_id" --yes
    fi
done

echo "Data directory configuration complete"