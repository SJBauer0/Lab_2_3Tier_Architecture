# EKS Module

This module provisions an Amazon Elastic Kubernetes Service (EKS) cluster and its associated worker node group, providing a scalable and managed environment for containerized workloads.

## Components

- **EKS Cluster**: A managed Kubernetes control plane deployed across multiple Availability Zones.
- **Node Group**: A managed group of EC2 instances that serve as the Kubernetes worker nodes. These nodes are deployed in private subnets for enhanced security.
- **IAM Roles and Policies**: Includes dedicated IAM roles for both the EKS cluster and the worker nodes, with specific policies attached to ensure secure operations (e.g., pulling images from ECR and interaction with the control plane).
- **VPC Configuration**: The cluster is integrated with the provided VPC and private subnets, ensuring all traffic between nodes and the control plane stays within the AWS network.

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| aws       | >= 5.0.0 |

## Inputs

| Name               | Description                                                | Type             | Default | Required |
| ------------------ | ---------------------------------------------------------- | ---------------- | ------- | :------: |
| project_name       | Name of the project used for naming and tagging resources. | `string`       | n/a     |   yes   |
| eks_version        | The version of Kubernetes for the EKS cluster.             | `string`       | n/a     |   yes   |
| subnet_ids         | List of subnet IDs for the cluster and node group.         | `list(string)` | n/a     |   yes   |
| node_instance_type | EC2 instance type for the worker nodes.                    | `string`       | n/a     |   yes   |
| node_min_size      | Minimum number of worker nodes in the scaling group.       | `number`       | 1       |    no    |
| node_max_size      | Maximum number of worker nodes in the scaling group.       | `number`       | 3       |    no    |
| node_desired_size  | Desired number of worker nodes in the scaling group.       | `number`       | 1       |    no    |

## Outputs

| Name                      | Description                                                      |
| ------------------------- | ---------------------------------------------------------------- |
| cluster_id                | The name of the EKS cluster.                                     |
| cluster_endpoint          | The endpoint for the EKS cluster API server.                     |
| cluster_security_group_id | Security group ID associated with the EKS cluster control plane. |
