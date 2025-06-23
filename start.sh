#!/bin/bash

echo "Starting SingleStore nodes..."

# Initialize /data directory for leaf nodes if needed
echo "Checking /data directory initialization..."

# Check if /data is empty (no memsql_id file)
if [ ! -f "/data/memsql_id" ]; then
    echo "/data directory is empty, initializing..."
    
    # Find all nodes that might be using /data (nodes showing as "Unknown" role)
    # First, let's find the leaf node directory by looking for port 3307
    leaf_datadir=$(find /var/lib/memsql -type d -name "data" | grep -E "3307" | head -1)
    
    if [ -z "$leaf_datadir" ]; then
        # If not found by port, look for any data directory that's not the master's
        for datadir in $(find /var/lib/memsql -type d -name "data"); do
            # Check if this is not the master node (port 3306)
            if ! grep -q "3306" <<< "$datadir"; then
                leaf_datadir="$datadir"
                break
            fi
        done
    fi
    
    if [ ! -z "$leaf_datadir" ] && [ -d "$leaf_datadir" ]; then
        echo "Found leaf node data directory: $leaf_datadir"
        echo "Copying initial data files to /data..."
        cp -R -p "$leaf_datadir"/* /data/
        chown -R memsql:memsql /data
        echo "Data files copied successfully"
    else
        echo "Warning: Could not find leaf node data directory"
    fi
else
    echo "/data directory already initialized"
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
