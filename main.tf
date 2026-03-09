# =============
#  Root Module
# =============


# 1. Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  vpc_cidr           = local.vpc_cidr
  availability_zones = var.availability_zone

  # Used to appropriately tag subnets for AWS Load Balancer Controller/EKS discovery
  eks_cluster_name = local.cluster_name
}

# 2. Database Module
module "database" {
  source = "./modules/database"

  project_name                  = var.project_name
  vpc_id                        = module.networking.vpc_id
  db_subnet_ids                 = module.networking.db_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  db_instance_class             = var.db_instance_class
  db_username                   = var.db_username
  db_password                   = var.db_password

  depends_on = [module.networking]
}

# 3. Elastic Kubernetes Service (EKS) Module
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name

  # EKS version to use 
  eks_version = local.eks_version
  subnet_ids  = module.networking.private_subnet_ids

  node_instance_type = var.node_instance_type

  depends_on = [module.networking]
}

# 4. Kubernetes Workloads Module
module "kubernetes_workloads" {
  source = "./modules/kubernetes_workloads"

  project_name = var.project_name
  db_endpoint  = module.database.db_endpoint

  backend_image  = var.backend_image
  frontend_image = var.frontend_image
  db_username    = var.db_username
  db_password    = var.db_password

  # This is required to ensure that the EKS node groups are created before the Kubernetes workloads
  eks_node_group_status = module.eks.cluster_id

  depends_on = [
    module.eks,
    module.database
  ]
}
