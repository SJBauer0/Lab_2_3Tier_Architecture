output "argocd_details" {
  description = "The login details and URL to access the Argo CD UI"
  value       = {
    url      = "https://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
    username = "admin"
    password = data.kubernetes_secret.argocd_admin_password.data["password"]
  }
  sensitive   = true
}

output "grafana_details" {
  description = "The login details and URL to access the Grafana UI"
  value       = {
    url      = "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}"
    username = "admin"
    password = data.kubernetes_secret.grafana_admin_password.data["admin-password"]
  }
  sensitive   = true
}

output "frontend_url" {
  description = "The URL to access the deployed frontend application"
  value       = "http://${data.kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].hostname}"
}
