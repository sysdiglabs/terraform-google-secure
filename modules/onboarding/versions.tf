terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 1.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}