resource "kubernetes_namespace_v1" "library_ns" {
  metadata {
    name = "library-app"
  }
}


resource "kubernetes_secret_v1" "db_secret" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }

  data = {
    POSTGRES_DB       = var.db_name
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
  }

  type = "Opaque"
}

# PersistentVolumeClaim para PostgreSQL
resource "kubernetes_persistent_volume_claim_v1" "postgres_pvc" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.postgres_storage_size
      }
    }
  }
}

# Deployment do Postgres
resource "kubernetes_deployment_v1" "database" {
  wait_for_rollout = false
  
  metadata {
    name      = "database"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
    labels = {
      app = "postgres"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "postgres" }
    }
    template {
      metadata {
        labels = { app = "postgres" }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:17"
          port { container_port = 5432 }
          
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.db_secret.metadata[0].name
            }
          }

          # Montagem do volume persistente
          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "postgres"
          }

          # Limites de recursos
          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          # Health checks
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user]
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "postgres-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim_v1.postgres_pvc]
}

# Serviço para o Postgres
resource "kubernetes_service_v1" "database_svc" {
  metadata {
    name      = "database"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}


resource "kubernetes_deployment_v1" "app" {
  wait_for_rollout = false
  
  metadata {
    name      = "app"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
    labels = {
      app = "django"
    }
  }
  spec {
    replicas = var.app_replicas
    selector {
      match_labels = {
        app = "django"
      }
    }
    template {
      metadata {
        labels = {
          app = "django"
        }
      }
      spec {
        container {
          name  = "django"
          image = var.app_image
          port {
            container_port = 8000
          }

          env {
            name  = "POSTGRES_DB"
            value = var.db_name
          }
          env {
            name  = "POSTGRES_USER"
            value = var.db_user
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "DATABASE_HOST"
            value = "database"
          }
          env {
            name  = "DATABASE_PORT"
            value = "5432"
          }

          # Limites de recursos
          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          args = ["tail", "-f", "/dev/null"]
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_v1.database_svc
  ]
}

# Serviço para a aplicação Django
resource "kubernetes_service_v1" "app_service" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "django"
    }
    port {
      port        = 8000
      target_port = 8000
      node_port   = 30000
    }
    type = "NodePort"
  }

  depends_on = [
    kubernetes_deployment_v1.app
  ]
}
