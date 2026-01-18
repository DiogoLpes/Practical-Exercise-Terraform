
# Secret com token de autenticação Basic Auth
resource "kubernetes_secret_v1" "basic_auth" {
  metadata {
    name      = "library-app-auth"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }

  type = "Opaque"

  data = {
    auth = base64encode("${var.auth_username}:${var.auth_password}")
  }
}





# Ingress padrão com múltiplos paths
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/notes"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.app_service.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}
