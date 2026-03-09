output "frontend_load_balancer_hostname" {
  description = "The hostname of the frontend LoadBalancer service"
  value       = kubernetes_service.frontend_service.status[0].load_balancer[0].ingress[0].hostname
}
