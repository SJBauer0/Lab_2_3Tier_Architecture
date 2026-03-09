variable "project_name" {
  description = "Labels for resources throught the project"
  default     = "lab-2-sjb-"
  type        = string
}

variable "availability_zone" {
  description = "Different AZs in the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  default     = "Admin12345"
  sensitive   = true
}

variable "backend_image" {
  description = "ECR URI for the backend container image"
  type        = string
  default     = "987470856504.dkr.ecr.us-east-1.amazonaws.com/lab-2-sjb-backend-ecr-repo:latest"
}

variable "frontend_image" {
  description = "ECR URI for the frontend container image"
  type        = string
  default     = "987470856504.dkr.ecr.us-east-1.amazonaws.com/lab-2-sjb-frontend-ecr-repo:latest"
}

variable "node_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "t3.small"
}

variable "db_instance_class" {
  description = "Instance type for the RDS database"
  type        = string
  default     = "db.t3.micro"
}