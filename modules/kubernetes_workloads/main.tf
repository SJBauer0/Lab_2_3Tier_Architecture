#######################
### Kubernetes Pods ###
#######################

# ---------------------------- #
#         BACKEND              #
# ---------------------------- #

# Backend Deployment configuring the pods running the API layer
resource "kubernetes_deployment" "backend_deployment" {
  metadata {
    name = "${var.project_name}-backend"
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name = "backend-container"

          # ECR URI
          image = var.backend_image

          port {
            container_port = 3001
          }

          # Using the compiled DB connection string for Prisma
          env {
            name = "DATABASE_URL"
            # RDS connection details
            value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}/postgres?schema=public"
          }

          # Kubernetes metadata passed into pods dynamically
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          # Kubernetes metadata passed into pods dynamically
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          # Kubernetes metadata passed into pods dynamically
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
        }
      }
    }
  }
}

# Backend Service for internal communication within the K8s cluster
resource "kubernetes_service" "backend_service" {
  metadata {
    name = "${var.project_name}-backend-service"
  }
  spec {
    selector = {
      app = "backend"
    }
    port {
      port        = 3001
      target_port = 3001
    }
    # ClusterIP ensures that this service is exposed inside the cluster ONLY
    type = "ClusterIP"
  }
}

# ---------------------------- #
#         FRONTEND             #
# ---------------------------- #

# Frontend Deployment configuring the pods running the React UI
resource "kubernetes_deployment" "frontend_deployment" {
  metadata {
    name = "${var.project_name}-frontend"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name = "frontend-container"

          # ECR URI
          image = var.frontend_image

          port {
            container_port = 3000
          }

          # Frontend container connects to internal Backend Service defined above
          env {
            name  = "INTERNAL_API_BASE_URL"
            value = "http://${kubernetes_service.backend_service.metadata[0].name}:3001"
          }

          # Identity metadata passed to containers
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          # Kubernetes metadata passed into pods dynamically
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          # Kubernetes metadata passed into pods dynamically
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
        }
      }
    }
  }
}

# Frontend LoadBalancer Service for external communication (to browser)
resource "kubernetes_service" "frontend_service" {
  metadata {
    name = "${var.project_name}-frontend-service"
  }
  spec {
    selector = {
      app = "frontend"
    }
    port {
      port        = 80 # Exposes HTTP
      target_port = 3000
    }
    # LoadBalancer provisions a Classic Load Balancer mapping internet traffic to pods
    type = "LoadBalancer"
  }
}
