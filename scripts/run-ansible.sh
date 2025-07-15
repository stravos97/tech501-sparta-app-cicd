#!/bin/bash

# Run Ansible playbook with retry logic
# This script runs the Ansible playbook with retry mechanism for reliability

set -e

PLAYBOOK_PATH="../tech501-ansible/playbooks/prov-app-all.yml"
INVENTORY_PATH="../tech501-ansible/inventory.yml"
MAX_RETRIES=3
RETRY_DELAY=30

echo "Starting Ansible playbook execution with retry logic..."
echo "Playbook: $PLAYBOOK_PATH"
echo "Inventory: $INVENTORY_PATH"
echo "Max retries: $MAX_RETRIES"

# Function to run Ansible playbook
run_ansible() {
    local attempt=$1
    echo "========================================="
    echo "Ansible execution attempt $attempt of $MAX_RETRIES"
    echo "========================================="
    
    cd ../tech501-ansible
    
    # Run the playbook
    if ansible-playbook -i inventory.yml playbooks/prov-app-all.yml -vvv; then
        echo "✅ Ansible playbook executed successfully on attempt $attempt"
        return 0
    else
        echo "❌ Ansible playbook failed on attempt $attempt"
        return 1
    fi
}

# Main retry loop
for attempt in $(seq 1 $MAX_RETRIES); do
    if run_ansible $attempt; then
        echo "🎉 Ansible configuration completed successfully!"
        exit 0
    else
        if [ $attempt -lt $MAX_RETRIES ]; then
            echo "⏳ Waiting $RETRY_DELAY seconds before retry..."
            sleep $RETRY_DELAY
        else
            echo "💥 All $MAX_RETRIES attempts failed. Ansible configuration failed."
            exit 1
        fi
    fi
done
