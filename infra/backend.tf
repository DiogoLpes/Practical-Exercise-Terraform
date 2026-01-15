resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.library_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "django" # Este label identifica o pod
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
          image = "python:3.12"

          # Mantém o container ligado para poderes copiar o código e rodar o poetry
          command = ["sh", "-c", "sleep infinity"]

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
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "app" 
    namespace = kubernetes_namespace.library_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "django" 
    }
    port {
      port        = 8000
      target_port = 8000
    }
    type = "NodePort"
  }
}