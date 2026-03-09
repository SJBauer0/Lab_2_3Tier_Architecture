locals {
  # Keep the EKS version central if it's meant to be static for the architecture version
  eks_version = "1.30"

  # VPC settings
  vpc_cidr = "172.16.0.0/16"

  # Standardize naming to prevent repetition
  cluster_name = "${var.project_name}-main-eks-cluster"

  # Common tags for all resources
  common_tags = {
    Project     = "Lab_2_3Tier_Architecture"
    Environment = "Dev"
    DeployedBy  = "Terraform"
  }
}
