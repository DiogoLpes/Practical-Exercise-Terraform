terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

provider "docker" {}

# Rede para os containers (equivalente ao database_network no compose)
resource "docker_network" "database_network" {
  name   = "database_network"
  driver = "bridge"
}

# Volume para persistência do Postgres (equivalente ao db_data)
resource "docker_volume" "db_data" {
  name = "db_data"
}

# Container do Banco de Dados (PostgreSQL 17)
resource "docker_container" "database" {
  name    = "database"
  image   = "postgres:17"
  restart = "always"
  networks_advanced {
    name = docker_network.database_network.name
  }
  
  # Variáveis baseadas no variables.tf
  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  ports {
    internal = 5432
    external = var.db_port
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }
}

# Container da Aplicação Django
resource "docker_container" "app" {
  name  = "app"
  image = "python:3.12" # Imagem base para rodar o seu pyproject.toml
  networks_advanced {
    name = docker_network.database_network.name
  }

  ports {
    internal = 8000
    external = var.app_port
  }

  # Monta o diretório atual no container (equivalente ao volume ./ no compose)
  volumes {
    host_path      = abspath(path.root)
    container_path = "/app"
  }

  working_dir = "/app"
  
  # Comando para manter o container vivo enquanto você roda as migrações via Makefile
  command = ["tail", "-f", "/dev/null"]

  depends_on = [docker_container.database]
}

# Container Adminer (Interface visual para o banco)
resource "docker_container" "adminer" {
  name    = "adminer"
  image   = "adminer"
  restart = "always"
  networks_advanced {
    name = docker_network.database_network.name
  }
  ports {
    internal = 8080
    external = 8080
  }
  depends_on = [docker_container.database]
}