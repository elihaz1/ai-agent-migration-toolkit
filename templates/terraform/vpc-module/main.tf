# VPC Module - Cloud Network Migration Toolkit
# Generic VPC module for hub-and-spoke architecture
# Supports GCP, can be adapted for AWS/Azure

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR range for the VPC (primary range)"
  type        = string
}

variable "region" {
  description = "Cloud region for resources"
  type        = string
  default     = "us-central1"
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    cidr                   = string
    private_google_access  = optional(bool, true)
    flow_logs_enabled      = optional(bool, true)
    secondary_ranges       = optional(map(string), {})
  }))
}

variable "enable_nat" {
  description = "Whether to create Cloud NAT for this VPC"
  type        = bool
  default     = false
}

variable "nat_static_ips" {
  description = "Number of static IPs to reserve for Cloud NAT"
  type        = number
  default     = 1
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460

  description = "Managed by Terraform - Cloud Migration Toolkit"
}

# Subnets
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets

  name          = "${var.vpc_name}-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = each.value.private_google_access

  # VPC Flow Logs (for security monitoring and troubleshooting)
  dynamic "log_config" {
    for_each = each.value.flow_logs_enabled ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  # Secondary IP ranges (e.g., for GKE pods and services)
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }
}

# Cloud Router (required for Cloud NAT)
resource "google_compute_router" "router" {
  count = var.enable_nat ? 1 : 0

  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id

  description = "Router for Cloud NAT"
}

# Reserve static IPs for Cloud NAT (optional but recommended)
resource "google_compute_address" "nat_ip" {
  count = var.enable_nat ? var.nat_static_ips : 0

  name   = "${var.vpc_name}-nat-ip-${count.index + 1}"
  region = var.region

  description = "Static IP for Cloud NAT"
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  count = var.enable_nat ? 1 : 0

  name   = "${var.vpc_name}-nat"
  router = google_compute_router.router[0].name
  region = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_ip[*].self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Enable logging for egress traffic monitoring
  log_config {
    enable = true
    filter = "ALL"
  }

  # Increase min ports per VM to avoid port exhaustion
  min_ports_per_vm = 16384
}

# Firewall Rules
# These are basic default rules; add more specific rules via the firewall module

# Allow IAP access (for bastion hosts)
resource "google_compute_firewall" "allow_iap" {
  name    = "${var.vpc_name}-allow-iap"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["35.235.240.0/20"] # Google IAP range

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"] # SSH and RDP
  }

  target_tags = ["bastion", "allow-iap"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  description = "Allow IAP access for bastion hosts (zero-trust admin access)"
}

# Allow health checks from Google load balancers
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.vpc_name}-allow-health-checks"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "35.191.0.0/16",    # Legacy health check range
    "130.211.0.0/22"    # Current health check range
  ]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  target_tags = ["allow-hc", "load-balanced"]

  description = "Allow health checks from Google Cloud Load Balancers"
}

# Default deny with logging (defense in depth)
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${var.vpc_name}-deny-all-ingress"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 65534 # Lowest priority (applied last)

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  description = "Default deny rule with logging (captures blocked traffic for security analysis)"
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in google_compute_subnetwork.subnet : k => v.id
  }
}

output "nat_external_ips" {
  description = "Static IPs used by Cloud NAT (if enabled)"
  value       = var.enable_nat ? google_compute_address.nat_ip[*].address : []
}
