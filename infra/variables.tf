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

variable "instance_type" {
  description = "Tipo de instancia EC2 para QA y Producción"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key pair para SSH (en AWS Academy normalmente se llama vockey)"
  type        = string
}
