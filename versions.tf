terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  alias = "no_user_project_override"
  user_project_override = false
}

provider "google" {
  user_project_override = true
} 

provider "google-beta" {
  user_project_override = true
}
