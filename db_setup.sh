#!/bin/bash

# This script provides a simplified, idempotent way to install and configure
# MongoDB 7.0.6 on an Ubuntu system.

# --- Script Configuration ---
set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Ensure pipeline failures are detected

# --- 1. Ensure script is run as root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1
fi

echo "--- Starting MongoDB Setup ---"

# --- 2. Add MongoDB GPG Key & Repository ---
echo "=> Configuring MongoDB Repository..."
sudo apt-get install gnupg curl -y
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor > /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg
echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
echo "Repository configured."

# --- 3. Update and Install MongoDB ---
echo "=> Installing MongoDB 7.0.6..."
apt-get update
apt-get install -y mongodb-org
echo "MongoDB installation complete."

# --- 4. Configure MongoDB to Listen on All IPs ---
echo "=> Configuring MongoDB..."
mongod_conf="/etc/mongod.conf"

# Use sed to replace the bindIp. This is idempotent.
# If the line is already correct, it does nothing.
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' "$mongod_conf"

# --- 5. Restart and Enable MongoDB Service ---
echo "=> Restarting and enabling MongoDB service..."
systemctl restart mongod
systemctl enable mongod
echo "MongoDB service is active and enabled."

# --- 6. Final Verification ---
echo "=> Verifying setup..."
mongod --version
systemctl status mongod --no-pager | grep "Active:"
grep "bindIp" "$mongod_conf"

echo "--- MongoDB Setup Complete ---"