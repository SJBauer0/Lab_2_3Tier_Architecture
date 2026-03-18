output "frontend_url" {
  description = "The URL to access the frontend application"
  value       = "http://${module.kubernetes_workloads.frontend_load_balancer_hostname}"
}
