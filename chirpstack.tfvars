# chirpstack.tfvars

is_remote = true
remote_docker = "192.168.1.10"
ssh_user = "devops"
ssh_private_key_path = "~/.ssh/infres.lab_privkey"
chirpstack_image_version = "4"
postgres_image_version   = "14-alpine"
redis_image_version      = "7-alpine"
mosquitto_image_version   = "2"
GatewayID                = "00800000a00016b6"
EventType                = "modem_UplinkResponse"
StateType                = "ONLINE"
postgres_password        = "root"
