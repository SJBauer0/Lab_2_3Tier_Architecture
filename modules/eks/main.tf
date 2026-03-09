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

###################
### EKS Cluster ###
###################

resource "aws_eks_cluster" "main_eks_cluster" {
  name     = "${var.project_name}-main-eks-cluster"
  version  = var.eks_version
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    # False means the API server cannot be accessed from within the VPC.
    endpoint_private_access = false
    # True means the API server can be accessed over the public internet.
    endpoint_public_access = true
    subnet_ids             = var.subnet_ids
  }

  # Ensure the EKS cluster is created after the IAM role and its policies are in place
  depends_on = [aws_iam_role_policy_attachment.EKSClusterPolicy]
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

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  # Ensure the node group waits for the required policies to be attached
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}
