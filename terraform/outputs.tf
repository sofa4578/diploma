
output "redis_host" {
  description = "Private IP of Redis instance"
  value       = module.redis.host
}

output "redis_auth" {
  description = "Redis AUTH token"
  value       = module.redis.auth_string
  sensitive   = true
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "artifact_registry" {
  description = "Docker registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/diploma-app-repo"
}
