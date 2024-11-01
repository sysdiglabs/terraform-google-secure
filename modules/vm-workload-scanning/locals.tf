locals {
  suffix = random_id.suffix[0].hex
}

resource "random_id" "suffix" {
  byte_length = 3
}
