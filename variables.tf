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