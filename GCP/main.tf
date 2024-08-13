# Define the VPC network for the European project
resource "google_compute_network" "vpc_network" {
  project                 = "europe-project"
  name                    = "europe-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Define the subnet within the European VPC
resource "google_compute_subnetwork" "subnets" {
  name          = "europe-public-subnet"
  ip_cidr_range = "192.168.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
}

# Serverless VPC Access connector for the Cloud Function
resource "google_vpc_access_connector" "connector" {
  name          = "europe-vpc-access-connector"
  region        = "europe-west1"
  ip_cidr_range = "192.168.9.0/28"
  network       = google_compute_network.vpc_network.name
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "./bigquery.zip"
}

# Cloud Function in Europe with VPC Access
resource "google_cloudfunctions_function" "google_cloud_function" {
  name                  = "europe-gcf-demo"
  description           = "Demonstrates IP checking in GCF"
  runtime               = "python3.11"
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  environment_variables = {
    PROJECT = "europe-project"
  }
  vpc_connector                 = google_vpc_access_connector.connector.name
  vpc_connector_egress_settings = "ALL_TRAFFIC"
  
  # HTTP trigger
  trigger_http = true

  entry_point  = "main"  # Ensure this is set to the name of the function in your code

  lifecycle {
    ignore_changes = [
      entry_point,
      labels,
      min_instances,
    ]
  }
}


# Allocate a static IP address for NAT in Europe
resource "google_compute_address" "nat_ip" {
  name   = "europe-gcf-nat-ip"
  region = "europe-west1"
}

# Create a Cloud Router for the European VPC
resource "google_compute_router" "router" {
  name    = "europe-gcf-router"
  region  = "europe-west1"
  network = google_compute_network.vpc_network.name
}

# Set up Cloud NAT in the European VPC
resource "google_compute_router_nat" "nat" {
  name                               = "europe-gcf-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules for the European VPC
resource "google_compute_firewall" "ingress_rule" {
  name          = "europe-allow-http-https-ingress"
  description   = "Allow HTTP and HTTPS traffic from specific IP range to Europe VPC"
  network       = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]  # Allow both HTTP and HTTPS traffic
  }
  source_ranges = ["35.199.224.0/19"]
  target_tags   = ["europe-http-server"]
}


resource "google_compute_firewall" "egress_rule" {
  name          = "europe-allow-outbound-traffic"
  description   = "Allow outbound HTTPS traffic from Europe VPC to the internet"
  network       = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = ["443"]  # Allow only outbound HTTPS (SSL) traffic
  }
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["europe-outbound-allowed"]
}