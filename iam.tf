####################
### IAM Policies ###
####################

data "aws_iam_policy_document" "eks_cluster_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service" 
      # The specific AWS service allowed to assume the role
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      # The worker nodes are just EC2 instances under the hood
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#############
### Roles ###
#############

resource "aws_iam_role" "eks_role" {
  name               = "${var.project_name}eks_role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_trust_policy.json
}

resource "aws_iam_role" "worker_eks_role" {
  name               = "${var.project_name}worker_eks_role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_trust_policy.json
}
#######################
### Role Attachment ###
#######################

resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  role = aws_iam_role.eks_role.name

  # Exact ARN of the existing AWS policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.worker_eks_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role = aws_iam_role.worker_eks_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.worker_eks_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}