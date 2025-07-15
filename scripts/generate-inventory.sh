#!/bin/bash

# Generate Ansible inventory from Terraform outputs
# This script creates a dynamic inventory file for Ansible based on Terraform outputs
# Updated to work with gcloud SSH wrapper

set -e

echo "Generating Ansible inventory from Terraform outputs..."

# Get IPs from command-line arguments
APP_EXTERNAL_IP=$1
APP_INTERNAL_IP=$2
DB_INTERNAL_IP=$3
APP_NAME=$4
DB_NAME=$5

echo "Retrieved IPs from arguments:"
echo "  App External IP: $APP_EXTERNAL_IP"
echo "  App Internal IP: $APP_INTERNAL_IP"
echo "  DB Internal IP: $DB_INTERNAL_IP"

# Create the inventory file
INVENTORY_FILE="../tech501-ansible/inventory.yml"

cat > "$INVENTORY_FILE" << EOF
all:
  children:
    web:
      hosts:
        $APP_NAME:
          ansible_host: $APP_NAME
          ansible_user: adminuser
          internal_ip: $APP_INTERNAL_IP
          external_ip: $APP_EXTERNAL_IP
    db:
      hosts:
        $DB_NAME:
          ansible_host: $DB_NAME
          ansible_user: adminuser
          internal_ip: $DB_INTERNAL_IP
EOF

echo "Ansible inventory generated at: $INVENTORY_FILE"
echo "Contents:"
cat "$INVENTORY_FILE"
