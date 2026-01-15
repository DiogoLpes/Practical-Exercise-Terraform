terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Namespace para organizar o projeto
resource "kubernetes_namespace" "library_ns" {
  metadata {
    name = "library-app"
  }
}

# Secret para as credenciais do banco (Baseado no teu .env)
resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.library_ns.metadata[0].name
  }

  data = {
    POSTGRES_DB       = var.db_name
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
  }
}

# Deployment do Postgres
resource "kubernetes_deployment" "database" {
  metadata {
    name      = "database"
    namespace = kubernetes_namespace.library_ns.metadata[0].name
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
              name = kubernetes_secret.db_secret.metadata[0].name
            }
          }
        }
      }
    }
  }
}

# Serviço para o Postgres (para o Django o encontrar)
resource "kubernetes_service" "database_svc" {
  metadata {
    name      = "database" # O Django usará este nome como HOST
    namespace = kubernetes_namespace.library_ns.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}