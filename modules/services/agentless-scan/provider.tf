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
      # TODO. restore when PR is merged https://github.com/sysdiglabs/terraform-provider-sysdig/pull/480
#      source  = "sysdiglabs/sysdig"

      # local testing with previous PR
      source = "terraform.example.com/sysdiglabs/sysdig"
      version = "~> 1.23.0"
    }
  }
}
