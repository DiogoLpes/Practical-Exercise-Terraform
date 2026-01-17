# Gerar certificado TLS auto-assinado
resource "tls_private_key" "library_app" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "library_app" {
  private_key_pem = tls_private_key.library_app.private_key_pem

  subject {
    common_name  = "library.local"
    organization = "Library App"
  }

  validity_period_hours = 100

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Secret com o certificado TLS
resource "kubernetes_secret_v1" "tls_cert" {
  metadata {
    name      = "library-app-tls"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.library_app.cert_pem
    "tls.key" = tls_private_key.library_app.private_key_pem
  }
}

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

# Instalar nginx-ingress controller via Helm
# (Minikube já traz nginx-ingress habilitado por padrão)

# Ingress com HTTPS e Basic Auth
resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "library-app-ingress"
    namespace = kubernetes_namespace_v1.library_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"               = "nginx"
      "nginx.ingress.kubernetes.io/auth-type"     = "basic"
      "nginx.ingress.kubernetes.io/auth-secret"   = kubernetes_secret_v1.basic_auth.metadata[0].name
      "nginx.ingress.kubernetes.io/auth-realm"    = "Library App"
      "nginx.org/controller-class"                = "nginx"
    }
  }

  spec {
    tls {
      hosts       = ["library.local"]
      secret_name = kubernetes_secret_v1.tls_cert.metadata[0].name
    }

    rule {
      host = "library.local"
      http {
        path {
          path      = "/"
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

  depends_on = [
    kubernetes_secret_v1.tls_cert,
    kubernetes_secret_v1.basic_auth
  ]
}
