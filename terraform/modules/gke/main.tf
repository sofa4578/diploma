
# ── Service Account для GKE нод (принцип мінімальних привілеїв) ──────────────
resource "google_service_account" "gke_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# ── GKE Cluster (приватний) ───────────────────────────────────────────────────
resource "google_container_cluster" "primary" {
  name     = "highload-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  # Приватні ноди — нема зовнішніх IP на воркерах
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false      # Master API доступний ззовні (для CI/CD)
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Vertical Pod Autoscaler — автоматично підбирає requests/limits
  vertical_pod_autoscaling {
    enabled = true
  }

  deletion_protection = false
}

# ── Node Pool з Cluster Autoscaler ───────────────────────────────────────────
resource "google_container_node_pool" "primary_nodes" {
  name     = "highload-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  # Cluster Autoscaler: автоматично додає/видаляє ноди
  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  node_config {
    machine_type    = "e2-standard-2"   # 2 vCPU, 8GB RAM
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    # Workload Identity — безпечніший спосіб авторизації подів
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
