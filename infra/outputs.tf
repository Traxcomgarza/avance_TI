output "rds_endpoint" {
  value = aws_db_instance.this.address
}

output "rds_port" {
  value = aws_db_instance.this.port
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app.id
}

output "qa_public_ip" {
  value = aws_instance.qa.public_ip
}

output "produccion_public_ip" {
  value = aws_instance.produccion.public_ip
}
