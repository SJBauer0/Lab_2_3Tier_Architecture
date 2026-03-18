output "argocd_url" {
  description = "The URL to access the Argo CD UI"
  value       = "https://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "grafana_url" {
  description = "The URL to access the Grafana UI"
  value       = "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}"
}

output "frontend_url" {
  description = "The URL to access the deployed frontend application"
  value       = "http://${data.kubernetes_service.frontend.status[0].load_balancer[0].ingress[0].hostname}"
}
