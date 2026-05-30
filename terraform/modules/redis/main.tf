
resource "google_redis_instance" "cache" {
  name           = "diploma-redis"
  tier           = "BASIC"          # BASIC достатньо для диплому
  memory_size_gb = 1
  region         = var.region
  redis_version  = "REDIS_7_0"

  # Авторизація паролем
  auth_enabled = true

  # Підключення через Private Service Access
  authorized_network = var.network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  # depends_on НЕ потрібен тут бо вказаний на рівні кореневого main.tf
  # через depends_on = [module.vpc] який містить private_vpc_connection
}
