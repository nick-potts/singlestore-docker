FROM debian:12.4-slim

ARG SDB_LICENSE
ARG SDB_PASSWORD

# Ensure up-to-date
RUN apt -y update

# Install packages needed to make Single Store work
RUN apt install -y openssh-server apt-transport-https gnupg2 wget net-tools jq

# Add Single Store sources
RUN wget -q -O - 'https://release.memsql.com/release-aug2018.gpg' | tee /etc/apt/trusted.gpg.d/memsql.asc 1>/dev/null
RUN echo "deb [arch=amd64] https://release.memsql.com/production/debian memsql main" | tee /etc/apt/sources.list.d/memsql.list
RUN apt -y update

# Install Single Store deps
RUN apt install -y singlestoredb-toolbox singlestore-client singlestore-studio

# Setup the node
RUN sdb-deploy cluster-in-a-box -y \
  --bind-address=0.0.0.0 \
  --license $SDB_LICENSE \
  --password $SDB_PASSWORD \
  --version 8.9

RUN sdb-admin list-nodes --json

# Copy scripts
COPY configure_datadir.sh /configure_datadir.sh
COPY start.sh /start.sh
RUN chmod +x /configure_datadir.sh /start.sh

# Create data directory
RUN mkdir -p /data

# Configure nodes to use /data directory
RUN /configure_datadir.sh

# Start all nodes
ENTRYPOINT ["/start.sh"]
