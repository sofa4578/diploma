
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # Remote state у GCS (bucket створюється вручну один раз)
  backend "gcs" {
    bucket = "diplomalevko-tf-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Artifact Registry для Docker образів
resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "diploma-app-repo"
  description   = "Docker images for Diploma FastAPI app"
  format        = "DOCKER"
}

# ── Модулі ────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "gke" {
  source     = "./modules/gke"
  project_id = var.project_id
  zone       = var.zone
  network_id   = module.vpc.network_id
  network_name = module.vpc.network_name
  subnet_id    = module.vpc.subnet_id
  subnet_name  = module.vpc.subnet_name
}

module "redis" {
  source     = "./modules/redis"
  region     = var.region
  network_id = module.vpc.network_id
  # Чекаємо поки VPC peering буде готовий
  depends_on = [module.vpc]
}
