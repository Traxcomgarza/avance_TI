variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base para nombrar los recursos"
  type        = string
  default     = "red-social-corta"
}

variable "bucket_name" {
  description = "Nombre del bucket S3 (debe ser único a nivel global)"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "redsocial"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  default     = "redsocial_app"
}

variable "db_password" {
  description = "Password de la base de datos (pásalo por TF_VAR_db_password, no lo hardcodees)"
  type        = string
  sensitive   = true
}

variable "app_instance_sg_id" {
  description = "Security Group de tu instancia EC2 (para permitir acceso a RDS solo desde ahí)"
  type        = string
}

variable "vpc_id" {
  description = "VPC donde vive tu instancia EC2 (AWS Academy suele tener una default)"
  type        = string
}

variable "subnet_ids" {
  description = "Al menos 2 subnets en distintas AZs para el subnet group de RDS"
  type        = list(string)
}
