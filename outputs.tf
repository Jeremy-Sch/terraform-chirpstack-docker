# Output values from Terraform
output "chirpstack_container_name" {
  value = [for c in docker_container.chirpstack : c.name]
}

output "chirpstack_external_port" {
  value = [for c in docker_container.chirpstack : c.ports.0.external]
}