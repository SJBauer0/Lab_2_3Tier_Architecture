####################
### IAM Policies ###
####################

# Trust policy for the EKS Cluster
data "aws_iam_policy_document" "eks_cluster_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type = "Service"
      # The specific AWS service allowed to assume the role
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Trust policy for the EKS Worker Nodes
data "aws_iam_policy_document" "eks_node_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type = "Service"
      # The worker nodes are EC2 instances under the hood
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#############
### Roles ###
#############

# IAM role for the EKS Cluster
resource "aws_iam_role" "eks_role" {
  name               = "${var.project_name}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_trust_policy.json

  tags = {
    Name = "${var.project_name}-eks-role"
  }
}

# IAM role for the EKS Worker Nodes
resource "aws_iam_role" "worker_eks_role" {
  name               = "${var.project_name}-worker-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_trust_policy.json

  tags = {
    Name = "${var.project_name}-worker-eks-role"
  }
}

#######################
### Role Attachment ###
#######################

# Attach AmazonEKSClusterPolicy to the EKS Cluster Role
resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach AmazonEKSWorkerNodePolicy to the Worker Node Role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.worker_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach AmazonEKS_CNI_Policy to the Worker Node Role (Networking)
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.worker_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach AmazonEC2ContainerRegistryReadOnly to allow nodes to pull images from ECR
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.worker_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach AmazonSSMManagedInstanceCore to allow SSM access to the worker nodes
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.worker_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

###################
### EKS Cluster ###
###################

resource "aws_eks_cluster" "main_eks_cluster" {
  name     = "${var.project_name}-main-eks-cluster"

  # The Kubernetes version for the EKS cluster for easy management and consistency across the architecture.
  version  = var.eks_version
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    # False means the API server cannot be accessed from within the VPC.
    # This is a common security best practice to limit access to the control plane
    # while still allowing access from the public internet for kubectl and other management tools.
    endpoint_private_access = false
    # True means the API server can be accessed over the public internet.
    endpoint_public_access = true
    subnet_ids             = var.subnet_ids
  }

  access_config {
    # This setting allows the use of EKS Access Entry to manage access to the EKS cluster.
    # This is the modern way to manage cluster access and is required to see cluster resources in the AWS Console.
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure the EKS cluster is created after the IAM role and its policies are in place
  depends_on = [aws_iam_role_policy_attachment.EKSClusterPolicy]
}

#######################
### EKS Cluster Access ###
#######################

# Grant cluster admin access to the provided IAM ARNs to see clusters, resources and compute in AWS console
resource "aws_eks_access_entry" "admin_access_entry" {
  # This allows multiple ARNs to be passed via variables and grants them admin access to the EKS cluster in the AWS Console.
  # toset function is used to convert the list of ARNs into a set, which is required for the for_each loop to iterate over 
  # each ARN and create an access entry for it.
  for_each      = toset(var.admin_arns)

  # The name of the EKS cluster to which access is being granted.
  cluster_name  = aws_eks_cluster.main_eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

# Grant cluster admin access to the provided IAM ARNs to see clusters, resources and compute in AWS console
resource "aws_eks_access_policy_association" "admin_policy_association" {
  # This allows multiple ARNs to be passed via variables and grants them admin access to the EKS cluster in the AWS Console.
  for_each      = toset(var.admin_arns)
  cluster_name  = aws_eks_cluster.main_eks_cluster.name

  # This is the ARN of the AmazonEKSClusterAdminPolicy, which grants full admin access to the EKS cluster in the AWS Console.
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

######################
### EKS Node Group ###
######################

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.main_eks_cluster.name
  node_group_name = "${var.project_name}-eks-nodes"
  node_role_arn   = aws_iam_role.worker_eks_role.arn
  version         = var.eks_version

  subnet_ids = var.subnet_ids

  # Instance type is customizable via variables
  instance_types = [var.node_instance_type]

  # Scaling configuration for the node group
  # This allows the node group to automatically scale based on the workload demands.
  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  # Ensure the node group waits for the required policies to be attached
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore
  ]
}
