variable "client" {
  description = "Client's name"
  type = string
  default = "null"
}

variable "db_name" {
  description = "Nome do banco de dados Postgres"
  type        = string
  default     = "library_db"
}

variable "db_user" {
  description = "Usuário mestre do banco de dados"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Senha para o banco de dados (deve coincidir com a definida no seu .env)"
  type        = string
  sensitive   = true
  default     = "Admin123" 
}

variable "db_port" {
  description = "Porta exposta do banco de dados"
  type        = number
  default     = 5432 
}

variable "app_port" {
  description = "Porta exposta da aplicação Django"
  type        = number
  default     = 8000 
}