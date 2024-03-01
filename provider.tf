# Set the required provider and versions
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Configure the docker provider
provider "docker" {
  host = var.is_remote ? "ssh://${var.ssh_user}@${var.remote_docker}" : "unix:///var/run/docker.sock"
  ssh_opts = var.is_remote ? [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-i", var.ssh_private_key_path
  ] : []
}