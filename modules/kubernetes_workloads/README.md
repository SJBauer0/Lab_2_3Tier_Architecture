# Kubernetes Workloads Module

This module deploys the backend and frontend application layers onto the EKS cluster, implementing the top two tiers of the 3-tier architecture.

## Components

### Backend Tier

- **Deployment**: Configures the backend pods, pulling the image from ECR and setting up the database connection via environment variables.
- **Service**: A ClusterIP service that allows the frontend to securely communicate with the backend within the cluster's internal network.

### Frontend Tier

- **Deployment**: Manages the frontend application pods (e.g., React UI), connecting to the backend service.
- **Service**: A LoadBalancer service that exposes the frontend application to the internet by provisioning an AWS Classic Load Balancer.

## Requirements

| Name       | Version  |
| ---------- | -------- |
| terraform  | >= 1.0.0 |
| kubernetes | >= 2.0.0 |

## Inputs

| Name                  | Description                                                    | Type       | Default | Required |
| --------------------- | -------------------------------------------------------------- | ---------- | ------- | :------: |
| project_name          | Name of the project for naming and labeling resources.         | `string` | n/a     |   yes   |
| backend_image         | The ECR URI for the backend container image.                   | `string` | n/a     |   yes   |
| frontend_image        | The ECR URI for the frontend container image.                  | `string` | n/a     |   yes   |
| db_endpoint           | The connection endpoint for the RDS instance.                  | `string` | n/a     |   yes   |
| db_username           | The master username for the database.                          | `string` | n/a     |   yes   |
| db_password           | The master password for the database.                          | `string` | n/a     |   yes   |
| eks_node_group_status | Used to ensure that the node group is ready before deployment. | `any`    | n/a     |   yes   |

## Outputs

| Name                 | Description                                                         |
| -------------------- | ------------------------------------------------------------------- |
| frontend_lb_hostname | The DNS name of the Load Balancer providing access to the frontend. |
