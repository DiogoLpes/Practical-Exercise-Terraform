# terraform {
#   required_providers {
#     minikube = {
#       source = "scott-the-programmer/minikube"
#       version = "0.6.0"
#     }
#     kubernetes = {
#       source = "hashicorp/kubernetes"
#       version = "3.0.1"
#     }
#   }
# }

# provider "minikube" {
  
# }

# provider "kubernetes" {
#   host = minikube_cluster.docker.host

#   client_certificate     = minikube_cluster.docker.client_certificate
#   client_key             = minikube_cluster.docker.client_key
#   cluster_ca_certificate = minikube_cluster.docker.cluster_ca_certificate
# }