variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "bacm-redsocial"
}

variable "bucket_name" {
  type = string
}

variable "db_name" {
  type    = string
  default = "facebook2"
}

variable "db_username" {
  type    = string
  default = "marksuckerberg"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "key_name" {
  type    = string
  default = "vockey"
}
