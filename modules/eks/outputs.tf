output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.main_eks_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main_eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the cluster control plane"
  value       = aws_eks_cluster.main_eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main_eks_cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main_eks_cluster.name
}
