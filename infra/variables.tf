variable "db_name" {
  description = "Nome da base de dados PostgreSQL"
  type        = string
  default     = "library_db"
}

variable "db_user" {
  description = "Utilizador da base de dados"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password da base de dados (SENSÍVEL)"
  type        = string
  sensitive   = true
  default     = "Admin123"
}

variable "postgres_storage_size" {
  description = "Tamanho do storage persistente do PostgreSQL"
  type        = string
  default     = "10Gi"
}

variable "app_image" {
  description = "Docker image para a aplicação Django"
  type        = string
  default     = "python:3.12"
}

variable "app_replicas" {
  description = "Número de réplicas para o deployment Django"
  type        = number
  default     = 1
}