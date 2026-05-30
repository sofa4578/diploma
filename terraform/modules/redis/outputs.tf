
output "host" {
  description = "Private IP of Redis"
  value       = google_redis_instance.cache.host
}

output "auth_string" {
  description = "Redis AUTH password"
  value       = google_redis_instance.cache.auth_string
  sensitive   = true
}
