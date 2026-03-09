terraform {
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Kubernetes provider for interacting with the EKS cluster
provider "kubernetes" {
  # Required to interact with the EKS cluster  
  host = module.eks.cluster_endpoint
  # Required to authenticate with the EKS cluster
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # The exec is for authentication with the EKS cluster using the AWS CLI
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}