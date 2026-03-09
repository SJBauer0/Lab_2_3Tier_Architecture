variable "project_name" {
  description = "Name of the project to prefix resources with"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the DB will be deployed"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs for the database"
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster, allowed to access the database"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Username for the database administrator"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database administrator"
  type        = string
  sensitive   = true
}
