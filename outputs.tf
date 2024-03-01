# Output values from Terraform
output "container_names" {
  value = [for c in docker_container.container : c.name]
}

output "container_external_ports" {
  value = [for c in docker_container.containerl : c.ports.0.external]
}