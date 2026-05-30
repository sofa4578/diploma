
# ── VPC ───────────────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  name                    = "diploma-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "diploma-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.0.0.0/16"
  private_ip_google_access = true   # Приватні ноди можуть звертатись до Google API
}

# ── Cloud Router + NAT (вихід у інтернет для приватних нод) ──────────────────
resource "google_compute_router" "router" {
  name    = "diploma-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "diploma-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ── Private Services Access (для Redis Memorystore) ───────────────────────────
resource "google_compute_global_address" "private_ip_range" {
  name          = "redis-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
