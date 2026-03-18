# =============
#  Root Module
# =============

# Fetch the current AWS identity to grant the cluster creator/admin access
data "aws_caller_identity" "current" {}

# Networking Module
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name

  # VPC CIDR block and availability zones for subnet distribution
  vpc_cidr = local.vpc_cidr

  # AZ list for subnet distribution
  availability_zones = var.availability_zone

  # Used to appropriately tag subnets for AWS Load Balancer Controller/EKS discovery
  eks_cluster_name = local.cluster_name
}

# Database Module
module "database" {
  source       = "./modules/database"
  project_name = var.project_name

  # VPC ID for the RDS database
  vpc_id = module.networking.vpc_id

  # Subnet IDs for the RDS database, which are the private subnets created in the networking module
  db_subnet_ids = module.networking.db_subnet_ids

  # Security group ID for the EKS cluster, which will be used to allow communication between the EKS cluster and the RDS database
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  # Database instance class (Currently, db.t3.micro) is customizable via variables
  db_instance_class = var.db_instance_class

  # Database credentials passed as environment variables to the backend application
  db_username = var.db_username
  db_password = var.db_password

  # Ensure the database is created after the VPC and subnets are in place
  depends_on = [module.networking]
}

# Elastic Kubernetes Service (EKS) Module
module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name

  # EKS version to use 
  eks_version = local.eks_version

  # Subnet IDs for the EKS cluster, which are the private subnets created in the networking module
  subnet_ids = module.networking.private_subnet_ids

  # Instance type for the EKS worker nodes (Currently set to t3.small)
  node_instance_type = var.node_instance_type

  # Pass the admin ARNs to grant access to EKS clusters in AWS Console
  admin_arns = [
    data.aws_caller_identity.current.arn
  ]

  # Ensure the EKS cluster is created after the VPC and subnets are in place
  depends_on = [module.networking]
}

# Install Argo CD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [module.eks]
}

# Install Prometheus & Grafana
resource "helm_release" "kube_prometheus_stack" {
  name             = "prometheus-grafana"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  depends_on = [module.eks]
}

# Fetch the Argo CD service to get its LoadBalancer URL
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

# Fetch the Grafana service to get its LoadBalancer URL
data "kubernetes_service" "grafana" {
  metadata {
    name      = "prometheus-grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.kube_prometheus_stack]
}

# Fetch the Frontend service to get its LoadBalancer URL
data "kubernetes_service" "frontend" {
  metadata {
    name      = "lab-2-sjb-frontend-service"
    namespace = "default"
  }
}
