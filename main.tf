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

# Define variables
variable "is_remote" {
  description = "Flag to indicate whether to use a remote Docker host over SSH."
  type        = bool
  default     = false
}

variable "remote_docker" {
  description = "IP address or hostname of the remote Docker host."
  type        = string
  nullable    = true
  default     = "127.0.0.1"
}

variable "ssh_user" {
  description = "SSH user for connecting to the remote Docker host."
  type        = string
  nullable    = true
  default     = "devops"
}

variable "ssh_private_key_path" {
  description = "SSH private key file path"
  type        = string
  nullable    = true
  default     = "/home/user/.ssh/privkey"
}

variable "chirpstack_image_version" {
  description = "ChirpStack Docker image version"
  default     = "4"
}

variable "postgres_image_version" {
  description = "PostgreSQL Docker image version"
  default     = "14-alpine"
}

variable "redis_image_version" {
  description = "Redis Docker image version"
  default     = "7-alpine"
}

variable "mosquitto_image_version" {
  description = "Eclipse Mosquitto Docker image version"
  default     = "2"
}

variable "GatewayID" {
  description = "Chirpstack Gateway ID"
  default     = "00800000a00016b6"
}

variable "EventType" {
  description = "Chirpstack Event Type"
  default     = "modem_UplinkResponse"
}

variable "StateType" {
  description = "Chirpstack State Type"
  default     = "ONLINE"
}

variable "postgres_password" {
  description = "PostgreSQL Root Password"
  default     = "root"
}

# Copy the configuration files
resource "null_resource" "copy_chirpstack_config" {
  count = var.is_remote ? 1 : 0  # Create only if is_remote is true
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/chirpstack/config",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /opt/chirpstack/config",  
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = var.remote_docker
    }
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -C -i ${var.ssh_private_key_path} -r ./configuration/* ${var.ssh_user}@${var.remote_docker}:/opt/chirpstack/config"
  }
}

# Create Docker volumes
resource "docker_volume" "postgres_volume" {
  name = "postgresql_data"
}

resource "docker_volume" "redis_volume" {
  name = "redis_data"
}

# Create a custom Docker network
resource "docker_network" "chirpstack_network" {
  name = "chirpstack_network"
}

# ChirpStack services
resource "docker_container" "chirpstack" {
  name    = "chirpstack"
  image   = "chirpstack/chirpstack:${var.chirpstack_image_version}"
  restart = "unless-stopped"

  command = ["-c", "/etc/chirpstack"]

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  ports {
    external = 8080
    internal = 8080
  }

  volumes {
    host_path	   = "/opt/chirpstack/config/chirpstack"
    container_path = "/etc/chirpstack"
  }

  depends_on = [null_resource.copy_chirpstack_config, docker_container.postgres, docker_container.mosquitto, docker_container.redis]

  env = [
    "MQTT_BROKER_HOST=mosquitto",
    "REDIS_HOST=redis",
    "POSTGRESQL_HOST=postgres",
  ]
}

# ChirpStack Gateway Bridge
resource "docker_container" "chirpstack_gateway_bridge" {
  name    = "chirpstack-gateway-bridge"
  image   = "chirpstack/chirpstack-gateway-bridge:${var.chirpstack_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  env = [
    "INTEGRATION__MQTT__EVENT_TOPIC_TEMPLATE=eu868/gateway/${var.GatewayID}/event/${var.EventType}",
    "INTEGRATION__MQTT__STATE_TOPIC_TEMPLATE=eu868/gateway/${var.GatewayID}/state/${var.StateType}",
    "INTEGRATION__MQTT__COMMAND_TOPIC_TEMPLATE=eu868/gateway/${var.GatewayID}/command/#",
  ]

  ports {
    external = 1700
    internal = 1700
    protocol = "udp"
  }

  volumes {
    host_path = "/opt/chirpstack/config/chirpstack-gateway-bridge"
    container_path = "/etc/chirpstack-gateway-bridge"
  }

  depends_on = [null_resource.copy_chirpstack_config, docker_container.mosquitto]
}

# ChirpStack Gateway Bridge BasicStattion
resource "docker_container" "chirpstack_gateway_bridge_basicstation" {
  name    = "chirpstack-gateway-bridge-basicstation"
  image   = "chirpstack/chirpstack-gateway-bridge:${var.chirpstack_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  command = ["-c", "/etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge-basicstation-eu868.toml"]

  ports {
    external = 3001
    internal = 3001
  }

  volumes {
    host_path = "/opt/chirpstack/config/chirpstack-gateway-bridge"
    container_path = "/etc/chirpstack-gateway-bridge"
  }

  depends_on = [null_resource.copy_chirpstack_config, docker_container.mosquitto]
}

# ChirpStack REST API
resource "docker_container" "chirpstack_rest_api" {
  name    = "chirpstack-rest-api"
  image   = "chirpstack/chirpstack-rest-api:${var.chirpstack_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  command = ["--server", "chirpstack:8080", "--bind", "0.0.0.0:8090", "--insecure"]

  ports {
    external = 8090
    internal = 8090
  }
  
  depends_on = [null_resource.copy_chirpstack_config, docker_container.chirpstack]
}

# PostgreSQL
resource "docker_container" "postgres" {
  name    = "postgres"
  image   = "postgres:${var.postgres_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  volumes {
    host_path      = "/opt/chirpstack/config/postgresql/initdb"
    container_path = "/docker-entrypoint-initdb.d"
  }

  volumes {
    volume_name    = docker_volume.postgres_volume.name
    container_path = "/var/lib/postgresql/data"
  }

  env = ["POSTGRES_PASSWORD=${var.postgres_password}"]
  depends_on = [null_resource.copy_chirpstack_config]
}

# Redis
resource "docker_container" "redis" {
  name    = "redis"
  image   = "redis:${var.redis_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  command = ["redis-server", "--save", "300", "1", "--save", "60", "100", "--appendonly", "no"]

  volumes {
    volume_name    = docker_volume.redis_volume.name
    container_path = "/data"
  }
}

# Mosquitto
resource "docker_container" "mosquitto" {
  name    = "mosquitto"
  image   = "eclipse-mosquitto:${var.mosquitto_image_version}"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.chirpstack_network.name
  }

  ports {
    external = 1883
    internal = 1883
  }

  volumes {
    host_path = "/opt/chirpstack/config/mosquitto/config"
    container_path = "/mosquitto/config"
  }
  depends_on = [null_resource.copy_chirpstack_config]
}
