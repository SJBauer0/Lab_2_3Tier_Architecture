###################
### EKS Cluster ###
###################

resource "aws_eks_cluster" "main_eks_cluster" {
  name     = "${var.project_name}-main-eks-cluster"
  version = local.eks_version
  role_arn = aws_iam_role.eks_role.arn
  
  vpc_config {    
    # The endpoint_private_access controls if the Kubernetes API server endpoint is accessible from within the VPC. 
    # False means that the API server cannot be accessed from within the VPC,
    # which enhance security by limiting access to the API server to only those with access to the public endpoint.
    endpoint_private_access = false
    # The endpoint_public_access allows you to control if the Kubernetes API server endpoint is accessible from the internet. 
    # True means the API server can be accessed over the public internet, which is necessary if you want to manage your cluster
    # from outside the VPC or if you have worker nodes in public subnets that need to communicate with the API server.
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.private_subnet_A.id,
      aws_subnet.private_subnet_B.id
    ]
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
  version = local.eks_version 
  
  subnet_ids = [
    aws_subnet.private_subnet_A.id, 
    aws_subnet.private_subnet_B.id
  ]
 
  instance_types = [ "t3.small" ]
  
  scaling_config {
    min_size     = 2
    max_size     = 2
    desired_size = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy, 
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly, 
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}