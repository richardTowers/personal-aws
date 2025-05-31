terraform {
  backend "s3" {
    bucket = "personal-aws-tfstate"
    key    = "gcp-bowman-dog"
    region = "eu-west-1"
  }
}

provider "google" {
  project = var.project_id
  region  = "europe-west1"
}

provider "google-beta" {
  project = var.project_id
  region  = "europe-west1"
}

resource "google_project_service" "photos_api" {
  project = var.project_id
  service = "photoslibrary.googleapis.com"
}

