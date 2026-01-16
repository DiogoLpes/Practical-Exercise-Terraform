terraform {
  required_version = ">= 1.0"
  
  # Descomente para usar remote backend (AWS S3, Terraform Cloud, etc.)
  # backend "s3" {
  #   bucket         = "my-terraform-state"
  #   key            = "library-app/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
  
  # Ou para Terraform Cloud:
  # cloud {
  #   organization = "your-org"
  #   workspaces {
  #     name = "library-app"
  #   }
  # }
}