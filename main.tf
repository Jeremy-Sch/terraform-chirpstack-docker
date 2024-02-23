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
  host = "unix:///var/run/docker.sock"
}

# Define variables
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
    host_path	   = "/opt/terraform/docker-chirpstack/configuration/chirpstack"
    container_path = "/etc/chirpstack"
  }

  depends_on = [docker_container.postgres, docker_container.mosquitto, docker_container.redis]

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
    "INTEGRATION__MQTT__EVENT_TOPIC_TEMPLATE=eu868/gateway/{{ var.GatewayID }}/event/{{ .EventType }}",
    "INTEGRATION__MQTT__STATE_TOPIC_TEMPLATE=eu868/gateway/{{ var.GatewayID }}/state/{{ .StateType }}",
    "INTEGRATION__MQTT__COMMAND_TOPIC_TEMPLATE=eu868/gateway/{{ var.GatewayID }}/command/#",
  ]

  ports {
    external = 1700
    internal = 1700
    protocol = "udp"
  }

  volumes {
    host_path = "/opt/terraform/docker-chirpstack/configuration/chirpstack-gateway-bridge"
    container_path = "/etc/chirpstack-gateway-bridge"
  }

  depends_on = [docker_container.mosquitto]
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
    host_path = "/opt/terraform/docker-chirpstack/configuration/chirpstack-gateway-bridge"
    container_path = "/etc/chirpstack-gateway-bridge"
  }

  depends_on = [docker_container.mosquitto]
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
  
  depends_on = [docker_container.chirpstack]
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
    host_path      = "/opt/terraform/docker-chirpstack/configuration/postgresql/initdb"
    container_path = "/docker-entrypoint-initdb.d"
  }

  volumes {
    volume_name    = docker_volume.postgres_volume.name
    container_path = "/var/lib/postgresql/data"
  }

  env = ["POSTGRES_PASSWORD=root"]
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
    host_path = "/opt/terraform/docker-chirpstack/configuration/mosquitto/config"
    container_path = "/mosquitto/config"
  }
}
