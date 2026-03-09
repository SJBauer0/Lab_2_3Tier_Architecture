variable "project_name" {
  description = "Name of the project to prefix resources with"
  type        = string
}

variable "db_endpoint" {
  description = "The RDS connection endpoint for the backend database"
  type        = string
}

variable "eks_node_group_status" {
  description = "Dependency dummy variable to ensure EKS node groups are created before deploying workloads"
  type        = any
  default     = null
}

variable "backend_image" {
  description = "The container image for the backend service"
  type        = string
}

variable "frontend_image" {
  description = "The container image for the frontend service"
  type        = string
}

variable "db_username" {
  description = "Username for the backend database connection"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the backend database connection"
  type        = string
  sensitive   = true
}
