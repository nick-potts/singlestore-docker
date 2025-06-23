#!/bin/bash

echo "Starting SingleStore nodes..."

# Initialize /data directory for leaf nodes if needed
echo "Checking /data directory initialization..."

# Get leaf node information
leaf_node_info=$(memsqlctl list-nodes --json | jq -r '.nodes[] | select(.role == "Leaf")')
if [ ! -z "$leaf_node_info" ]; then
    leaf_node_id=$(echo "$leaf_node_info" | jq -r '.memsqlId')
    
    # Check if /data is empty (no memsql_id file)
    if [ ! -f "/data/memsql_id" ]; then
        echo "Initializing /data directory for leaf node..."
        
        # Find the original data directory for the leaf node
        original_datadir=$(find /var/lib/memsql -name "data" -path "*${leaf_node_id:0:10}*" 2>/dev/null | head -1)
        
        if [ ! -z "$original_datadir" ] && [ -d "$original_datadir" ]; then
            echo "Copying initial data files from $original_datadir to /data..."
            cp -R -p "$original_datadir"/* /data/
            chown -R memsql:memsql /data
            echo "Data files copied successfully"
        else
            echo "Warning: Could not find original data directory for leaf node"
        fi
    else
        echo "/data directory already initialized"
    fi
fi

# Show current node status
echo "Current node status:"
sdb-admin list-nodes

# Start all nodes
echo "Starting all nodes..."
sdb-admin start-node --all --yes

# Check final status
echo "Final node status:"
sdb-admin list-nodes

# Keep the script running
tail -f /dev/null
