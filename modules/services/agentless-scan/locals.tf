locals {
  suffix = var.suffix == null ? random_id.suffix[0].hex : var.suffix
}


resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}