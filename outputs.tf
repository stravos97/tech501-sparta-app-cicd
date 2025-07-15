output "app_instance_external_ip" {
  value       = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
  description = "The external IP address of the app instance."
}

output "app_instance_internal_ip" {
  value       = google_compute_instance.app_instance.network_interface[0].network_ip
  description = "The internal IP address of the app instance."
}

output "db_instance_internal_ip" {
  value       = google_compute_instance.db_instance.network_interface[0].network_ip
  description = "The internal IP address of the db instance."
}

output "app_instance_name" {
  value       = google_compute_instance.app_instance.name
  description = "The name of the app instance."
}

output "db_instance_name" {
  value       = google_compute_instance.db_instance.name
  description = "The name of the db instance."
}

output "ssh_command_app_instance" {
  value       = "ssh -i gcp-sparta-ssh-key adminuser@${google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip}"
  description = "SSH command to connect to the app instance."
}

output "db_instance_external_ip" {
  value       = google_compute_instance.db_instance.network_interface[0].access_config[0].nat_ip
  description = "The external IP address of the db instance."
}

output "ssh_command_db_instance" {
  value       = "ssh -i gcp-sparta-ssh-key adminuser@${google_compute_instance.db_instance.network_interface[0].access_config[0].nat_ip}"
  description = "SSH command to connect to the db instance."
}