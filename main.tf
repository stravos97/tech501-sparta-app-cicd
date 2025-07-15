terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "gcp-sparta"
  region  = "us-central1"
}

resource "google_compute_network" "default_network" {
  name                    = "default"
  auto_create_subnetworks = true
  routing_mode            = "REGIONAL"
  description             = "Default network for the project"
}

resource "google_compute_network" "two_tier_vpc" {
  name                    = "two-tier-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.two_tier_vpc.self_link
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.two_tier_vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_app_port_3000" {
  name          = "allow-app-port-3000"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app-server"]
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
  description = "Allows ingress TCP traffic on port 3000 to instances with the app-server tag."
}

resource "google_compute_firewall" "allow_db_access" {
  name        = "allow-db-access"
  network     = google_compute_network.two_tier_vpc.self_link
  direction   = "INGRESS"
  priority    = 1000
  source_tags = ["web-server"]
  target_tags = ["db-server"]
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
}

resource "google_compute_firewall" "allow_http" {
  name          = "allow-http"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name          = "allow-iap-ssh"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_mongo_db" {
  name        = "allow-mongo-db"
  network     = google_compute_network.two_tier_vpc.self_link
  direction   = "INGRESS"
  priority    = 1000
  source_tags = ["web-server"]
  target_tags = ["db-server"]
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
}

resource "google_compute_firewall" "allow_ssh_external_insecure" {
  name          = "allow-ssh-external-insecure"
  network       = google_compute_network.default_network.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name          = "allow-ssh-iap"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_ssh_to_web_server" {
  name          = "allow-ssh-to-web-server"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow SSH from any IP to instances with the web-server tag on the two-tier-vpc network."
}

resource "google_compute_firewall" "allow_ssh_two_tier" {
  name          = "allow-ssh-two-tier"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow SSH from any IP on the two-tier-vpc network."
}

resource "google_compute_firewall" "default_allow_icmp" {
  name          = "default-allow-icmp"
  network       = google_compute_network.default_network.self_link
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
  description = "Allow ICMP from anywhere"
}

resource "google_compute_firewall" "default_allow_internal" {
  name          = "default-allow-internal"
  network       = google_compute_network.default_network.self_link
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["10.128.0.0/9"]
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  description = "Allow internal traffic on the default network"
}

resource "google_compute_firewall" "default_allow_rdp" {
  name          = "default-allow-rdp"
  network       = google_compute_network.default_network.self_link
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  description = "Allow RDP from anywhere"
}

resource "google_compute_firewall" "default_allow_ssh" {
  name          = "default-allow-ssh"
  network       = google_compute_network.default_network.self_link
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  description = "Allow SSH from anywhere"
}

resource "google_compute_firewall" "two_tier_vpc_allow_http" {
  name          = "two-tier-vpc-allow-http"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "two_tier_vpc_allow_https" {
  name          = "two-tier-vpc-allow-https"
  network       = google_compute_network.two_tier_vpc.self_link
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow_db_egress_http_https" {
  name               = "allow-db-egress-http-https"
  network            = google_compute_network.two_tier_vpc.self_link
  direction          = "EGRESS"
  priority           = 1000
  target_tags        = ["db-server"]
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  description = "Allows egress HTTP/HTTPS traffic from db-server instances to the internet."
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  region  = "us-central1"
  network = google_compute_network.two_tier_vpc.self_link
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance" "app_instance" {
  name           = "app-instance"
  machine_type   = "e2-micro"
  zone           = "us-central1-a"
  project        = "gcp-sparta"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.two_tier_vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = "155517448706-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["app-server", "web-server"]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
}

resource "google_compute_address" "db_static_ip" {
  name = "db-static-ip"
}

resource "google_compute_instance" "db_instance" {
  name         = "db-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  project      = "gcp-sparta"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.two_tier_vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
      nat_ip = google_compute_address.db_static_ip.address
    }
  }

  service_account {
    email  = "155517448706-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["db-server"]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
  allow_stopping_for_update = true
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "gcp-sparta-ssh-key"
  file_permission = "0600"
}

resource "google_compute_project_metadata" "ssh_key" {
  metadata = {
    ssh-keys = "adminuser:${tls_private_key.ssh.public_key_openssh}"
  }
}


# resource "null_resource" "ansible_provisioning" {
#   # This resource will be recreated if any of the instances change
#   triggers = {
#     app_instance_id = google_compute_instance.app_instance.id
#     db_instance_id  = google_compute_instance.db_instance.id
#   }

#   # Wait for instances to be ready
#   provisioner "local-exec" {
#     command = "echo 'Waiting for instances to be ready...' && sleep 90"
#   }

#   # Generate Ansible inventory
#   provisioner "local-exec" {
#     command = "./scripts/generate-inventory.sh ${google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip} ${google_compute_instance.app_instance.network_interface[0].network_ip} ${google_compute_instance.db_instance.network_interface[0].network_ip} ${google_compute_instance.app_instance.name} ${google_compute_instance.db_instance.name}"
#   }

#   # Wait a bit more for SSH to be ready
#   provisioner "local-exec" {
#     command = "echo 'Waiting for SSH to be ready...' && sleep 60"
#   }

#   # Run Ansible playbook with retry logic
#   provisioner "local-exec" {
#     command = "./scripts/run-ansible.sh"
#   }

#   depends_on = [
#     google_compute_instance.app_instance,
#     google_compute_instance.db_instance
#   ]
# }
