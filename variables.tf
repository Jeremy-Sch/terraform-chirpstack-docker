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
}

variable "ssh_user" {
  description = "SSH user for connecting to the remote Docker host."
  type        = string
  nullable    = true
  default     = "user"
}

variable "ssh_private_key_path" {
  description = "SSH private key file path."
  type        = string
  nullable    = true
  default     = "/home/user/.ssh/privkey"
}

variable "chirpstack_config_path" {
  description = "Path of the Chirpstack configuration"
  type        = string
  default     = "/opt/chirpstack/config"
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
  default     = "S!cureP@ssword"
}