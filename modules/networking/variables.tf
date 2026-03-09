variable "project_name" {
  description = "Name of the project to prefix resources with"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster (used for tagging subnets for EKS discovery)"
  type        = string
}
