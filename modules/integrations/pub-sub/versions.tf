terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 3.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.7.0"
    }
  }
}
