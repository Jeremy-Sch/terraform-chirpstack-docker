# ChirpStack Deployment with Docker and Terraform

## Overview

This project automates the deployment of ChirpStack components using Docker containers with Terraform.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/)
- [Docker](https://www.docker.com/)

## Getting Started

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/chirpstack-docker-terraform.git
    cd chirpstack-docker-terraform
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Apply the Terraform configuration:

    ```bash
    terraform apply
    ```

## Usage

Once the deployment is complete, you can access ChirpStack services at the following URLs:

- ChirpStack Application Server: [http://localhost:8080](http://localhost:8080)
- ChirpStack Gateway Bridge: [http://localhost:1700](http://localhost:1700)
- ChirpStack REST API: [http://localhost:8090](http://localhost:8090)

## Configuration

Adjust the configuration in the Terraform files (`main.tf`) to customize settings such as ChirpStack version, network configurations, etc.

## Docker Containers

The project uses the following Docker containers:

1. **chirpstack**
   - ChirpStack Application Server

2. **chirpstack_gateway_bridge**
   - ChirpStack Gateway Bridge

3. **chirpstack_gateway_bridge_basicstation**
   - ChirpStack Gateway Bridge with BasicStation support

4. **chirpstack_rest_api**
   - ChirpStack REST API

5. **mosquitto**
   - Eclipse Mosquitto MQTT Broker

## Contributing

Feel free to contribute by submitting issues or pull requests. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- ChirpStack: [https://www.chirpstack.io/](https://www.chirpstack.io/)
- Terraform: [https://www.terraform.io/](https://www.terraform.io/)
- Docker: [https://www.docker.com/](https://www.docker.com/)