# Networking Module

This module manages the core networking infrastructure on AWS, providing a secure and scalable foundation for the 3-tier architecture. It implements a Virtual Private Cloud (VPC) with public, private, and isolated database subnets across multiple Availability Zones.

## Components

- **VPC**: A dedicated Virtual Private Cloud with a configurable CIDR block.
- **Public Subnets**: Hosted in two Availability Zones, these subnets include an Internet Gateway and are used for resources that require direct internet access, such as NAT Gateways and External Load Balancers.
- **Private Subnets**: Hosted in two Availability Zones, these subnets are used for the EKS worker nodes and backend applications. Outbound internet access is provided via NAT Gateways.
- **Database Subnets**: Isolated subnets dedicated to the RDS instance, with no direct route to the internet for enhanced security.
- **NAT Gateways**: Deployed in public subnets to allow resources in private subnets to securely access the internet for updates and external API calls.
- **Internet Gateway**: Enables communication between the VPC and the internet.

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| aws       | >= 5.0.0 |

## Inputs

| Name               | Description                                         | Type             | Default | Required |
| ------------------ | --------------------------------------------------- | ---------------- | ------- | :------: |
| project_name       | Name of the project used for tagging resources.     | `string`       | n/a     |   yes   |
| vpc_cidr           | The CIDR block for the VPC.                         | `string`       | n/a     |   yes   |
| availability_zones | List of Availability Zones for subnet distribution. | `list(string)` | n/a     |   yes   |
| eks_cluster_name   | Name of the EKS cluster for tagging subnets.        | `string`       | n/a     |   yes   |

## Outputs

| Name               | Description                           |
| ------------------ | ------------------------------------- |
| vpc_id             | The ID of the created VPC.            |
| public_subnet_ids  | List of IDs for the public subnets.   |
| private_subnet_ids | List of IDs for the private subnets.  |
| db_subnet_ids      | List of IDs for the database subnets. |
