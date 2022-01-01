output "s3_bucket_name" {
  value = [aws_s3_bucket.s3-bucket.id]
}

output "ip_addr" {
  value       = aws_instance.vault.public_ip
  description = "The IP addresses of the deployed instances, paired with their IDs."
}

output "http_link" {
  value       = "http://${aws_instance.vault.public_ip}:8200"
  description = "HTTP Link Address"
}