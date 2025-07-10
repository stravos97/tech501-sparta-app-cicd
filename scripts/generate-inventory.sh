#!/bin/bash

# Generate Ansible inventory from Terraform outputs
# This script creates a dynamic inventory file for Ansible based on Terraform outputs
# Updated to work with gcloud SSH wrapper

set -e

echo "Generating Ansible inventory from Terraform outputs..."

# Get Terraform outputs
APP_EXTERNAL_IP=$(terraform output -raw app_instance_external_ip)
APP_INTERNAL_IP=$(terraform output -raw app_instance_internal_ip)
DB_INTERNAL_IP=$(terraform output -raw db_instance_internal_ip)
APP_NAME=$(terraform output -raw app_instance_name)
DB_NAME=$(terraform output -raw db_instance_name)

echo "Retrieved IPs:"
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
