output "s3_bucket_name" {
  value = aws_s3_bucket.incidents_bucket.id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}
