# Terraform + Ansible Integration

This project integrates Terraform for infrastructure provisioning with Ansible for configuration management, providing a robust and reproducible deployment solution.

## Overview

The integration combines:
- **Terraform**: Creates GCP infrastructure (VMs, networks, firewall rules)
- **Ansible**: Configures software on the VMs (MongoDB 7.0.6, Node.js 20.x, PM2, Nginx)

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Terraform     │    │    Ansible      │
│                 │    │                 │
│ • Creates VMs   │───▶│ • MongoDB 7.0.6 │
│ • Sets up VPC   │    │ • Node.js 20.x  │
│ • Firewall      │    │ • PM2 + Nginx   │
│ • SSH keys      │    │ • App deployment│
└─────────────────┘    └─────────────────┘
```

## Key Features

✅ **MongoDB 7.0.6** - Specific version, not generic  
✅ **Node.js 20.x** - Latest LTS with PM2 process management  
✅ **Nginx Reverse Proxy** - Production-ready web server  
✅ **Database Seeding** - Automated data initialization  
✅ **Health Checks** - Built-in verification and debugging  
✅ **Retry Logic** - 3 attempts with 30-second delays  
✅ **SSH Tunneling** - Secure access to private DB instance  

## File Structure

```
/deloitte/
├── main.tf                    # Terraform infrastructure
├── variables.tf               # Terraform variables
├── outputs.tf                 # Terraform outputs (IPs, names)
├── terraform.tfvars           # Configuration values
├── scripts/
│   ├── generate-inventory.sh  # Creates Ansible inventory
│   └── run-ansible.sh         # Runs Ansible with retry
└── ../tech501-ansible/
    ├── ansible.cfg            # Ansible configuration
    ├── inventory.yml          # Dynamic inventory (generated)
    └── playbooks/
        └── prov-app-all.yml   # Main provisioning playbook
```

## Deployment Workflow

1. **Terraform Apply**
   ```bash
   terraform apply
   ```

2. **Automatic Process**:
   - VMs created with SSH keys
   - Wait 60 seconds for instances to boot
   - Generate Ansible inventory with actual IPs
   - Wait 30 seconds for SSH to be ready
   - Run Ansible playbook (with retry logic)

3. **Result**: Fully configured application stack

## Infrastructure Details

### App Instance (Public Subnet)
- **Machine Type**: e2-micro
- **Image**: debian-cloud/debian-11
- **Network**: Public subnet (10.0.1.0/24)
- **Access**: External IP + SSH key
- **Software**: Node.js 20.x, PM2, Nginx

### DB Instance (Private Subnet)
- **Machine Type**: e2-micro
- **Image**: debian-cloud/debian-11
- **Network**: Private subnet (10.0.2.0/24)
- **Access**: SSH tunnel through app instance
- **Software**: MongoDB 7.0.6 (listening on 0.0.0.0)

### Networking
- **VPC**: two-tier-vpc
- **Firewall Rules**:
  - HTTP (80) → App instance
  - App (3000) → App instance
  - MongoDB (27017) → DB instance (from app only)
  - SSH (22) → Both instances

## Ansible Configuration

### Key Improvements
- **Debian 11 Support**: Updated repositories for GCP images
- **SSH Tunneling**: Secure access to private DB instance
- **Dynamic Inventory**: Generated from Terraform outputs
- **Retry Logic**: Handles transient failures
- **Health Verification**: Comprehensive status checks

### Database Configuration
```yaml
db_host: "mongodb://{{ hostvars[groups['db'][0]]['internal_ip'] }}:27017/posts"
```

### SSH Configuration
```yaml
ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa adminuser@APP_EXTERNAL_IP"'
```

## Usage

### Deploy Infrastructure
```bash
terraform apply
```

### Manual Ansible Run (if needed)
```bash
cd ../tech501-ansible
ansible-playbook -i inventory.yml playbooks/prov-app-all.yml -v
```

### Access Application
- **Web Interface**: `http://<APP_EXTERNAL_IP>`
- **Direct App**: `http://<APP_EXTERNAL_IP>:3000`

### SSH Access
```bash
# App instance (direct)
ssh -i ~/.ssh/id_rsa adminuser@<APP_EXTERNAL_IP>

# DB instance (through app instance)
ssh -i ~/.ssh/id_rsa -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_rsa adminuser@<APP_EXTERNAL_IP>" adminuser@<DB_INTERNAL_IP>
```

## Troubleshooting

### Check Terraform Outputs
```bash
terraform output
```

### Verify Ansible Inventory
```bash
cat ../tech501-ansible/inventory.yml
```

### Manual Inventory Generation
```bash
./scripts/generate-inventory.sh
```

### Manual Ansible Run with Retry
```bash
./scripts/run-ansible.sh
```

### Check Application Status
```bash
# On app instance
pm2 list
systemctl status nginx
curl localhost:3000

# On db instance
systemctl status mongod
mongo --eval "db.adminCommand('ismaster')"
```

## Benefits Over Previous Setup

| Aspect | Before (Startup Scripts) | After (Terraform + Ansible) |
|--------|-------------------------|------------------------------|
| **MongoDB** | Generic package | Specific 7.0.6 version |
| **Configuration** | Basic setup | Proper bindIp, service config |
| **Node.js** | System package | NodeSource 20.x LTS |
| **Process Management** | Basic PM2 | Proper PM2 with startup |
| **Error Handling** | None | Retry logic + health checks |
| **Debugging** | Limited | Comprehensive status info |
| **Reproducibility** | Variable | 100% consistent |
| **Maintainability** | Hard to update | Version controlled |

## Security Features

- **SSH Key Authentication**: No password access
- **Private DB Instance**: No direct internet access
- **SSH Tunneling**: Secure database access
- **Firewall Rules**: Minimal required ports only
- **Service Accounts**: Proper GCP permissions

## Monitoring & Health Checks

The Ansible playbook includes comprehensive health checks:
- MongoDB version verification
- Service status monitoring
- Port availability checks
- Configuration validation
- Application startup verification

## Future Enhancements

- **SSL/TLS**: Add HTTPS support
- **Monitoring**: Integrate with GCP monitoring
- **Backup**: Automated MongoDB backups
- **Scaling**: Auto-scaling groups
- **CI/CD**: Jenkins integration
- **Secrets**: Vault integration for sensitive data
