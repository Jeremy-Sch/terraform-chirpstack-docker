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
    git clone https://github.com/Jeremy-Sch/terraform-chirpstack-docker.git
    cd chirpstack-docker-terraform
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Modify variables:

    ```bash
    nano chirpstack.tfvars
    ```

4. Check the configuration:

    ```bash
    terraform validate
    ```

5. Apply the Terraform configuration:

    ```bash
    terraform apply -var-file="chirpstack.tfvars"
    ```

## Usage

Once the deployment is complete, you can access ChirpStack services at the following URLs:

- ChirpStack Application Server: [http://localhost:8080](http://localhost:8080)

## Configuration

Adjust the configuration in the Terraform variable definitions file (`chirpstack.tfvars`) to customize settings such as ChirpStack version, etc.

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

6. **mosquitto**
   - Eclipse Mosquitto MQTT Broker
7. **redis**
   -  Redis database

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- ChirpStack: [https://www.chirpstack.io/](https://www.chirpstack.io/)
- Terraform: [https://www.terraform.io/](https://www.terraform.io/)
- Docker: [https://www.docker.com/](https://www.docker.com/)
