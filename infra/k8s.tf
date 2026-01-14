resource "minikube_cluster" "docker" {
  cluster_name = var.client
  nodes = 1
}

resource "kubernetes_namespace_v1" "name" {
    metadata {
      name = "app"
    }
}

