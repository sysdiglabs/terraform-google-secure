terraform {
  required_version = ">=1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.1, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1, < 4.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.23.1"
    }
  }
}
