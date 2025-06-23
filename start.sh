#!/bin/bash

echo "Starting SingleStore nodes..."

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
