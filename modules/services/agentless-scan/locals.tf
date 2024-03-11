locals {
  suffix = var.suffix == null ? random_id.suffix[0].hex : var.suffix

  is_organizational = var.is_organizational && var.organization_domain != null ? 1 : 0

  host_discovery_permissions = [
    # networks
    "compute.networks.list",
    "compute.networks.get",
    # instances
    "compute.instances.list",
    "compute.instances.get",
    # disks
    "compute.disks.list",
    "compute.disks.get",
    # workload identity federation
    "iam.serviceAccounts.getAccessToken",
  ]

  host_scan_permissions = [
    # general stuff
    "compute.zoneOperations.get",
    # disks
    "compute.disks.get",
    "compute.disks.useReadOnly",
  ]
}


resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}