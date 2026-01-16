output "namespace" {
  description = "Namespace onde a aplicação está deployed"
  value       = kubernetes_namespace_v1.library_ns.metadata[0].name
}

output "app_service_name" {
  description = "Nome do serviço da aplicação Django"
  value       = kubernetes_service_v1.app_service.metadata[0].name
}

output "app_service_nodeport" {
  description = "NodePort do serviço Django"
  value       = kubernetes_service_v1.app_service.spec[0].port[0].node_port
}

output "database_service_name" {
  description = "Nome do serviço da base de dados"
  value       = kubernetes_service_v1.database_svc.metadata[0].name
}

output "app_deployment_name" {
  description = "Nome do deployment da aplicação"
  value       = kubernetes_deployment_v1.app.metadata[0].name
}
