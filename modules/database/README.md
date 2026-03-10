# Database Module

This module provisions an Amazon RDS PostgreSQL instance designed for high availability and security within the 3-tier architecture.

## Components

- **RDS PostgreSQL Instance**: A managed database instance running PostgreSQL. It is configured with Multi-AZ deployment to ensure reliability across Availability Zones.
- **Security Group**: A dedicated security group that restricts incoming traffic to only allowed sources, specifically the EKS cluster nodes on the PostgreSQL port (5432).
- **Subnet Group**: A logical grouping of private database subnets within the VPC where the RDS instance will be deployed.

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| aws       | >= 5.0.0 |

## Inputs

| Name                          | Description                                                     | Type             | Default | Required |
| ----------------------------- | --------------------------------------------------------------- | ---------------- | ------- | :------: |
| project_name                  | Name of the project used for naming and tagging resources.      | `string`       | n/a     |   yes   |
| vpc_id                        | The ID of the VPC where the database will be created.           | `string`       | n/a     |   yes   |
| db_subnet_ids                 | List of subnet IDs for the database subnet group.               | `list(string)` | n/a     |   yes   |
| eks_cluster_security_group_id | Security group ID of the EKS cluster nodes for database access. | `string`       | n/a     |   yes   |
| db_instance_class             | The instance type for the RDS instance.                         | `string`       | n/a     |   yes   |
| db_username                   | The master username for the database.                           | `string`       | n/a     |   yes   |
| db_password                   | The master password for the database.                           | `string`       | n/a     |   yes   |
| db_allocated_storage          | The amount of storage to allocate to the RDS instance in GiB.   | `number`       | 20      |    no    |

## Outputs

| Name           | Description                                   |
| -------------- | --------------------------------------------- |
| db_endpoint    | The connection endpoint for the RDS instance. |
| db_instance_id | The unique identifier for the RDS instance.   |
