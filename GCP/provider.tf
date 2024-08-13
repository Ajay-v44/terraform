# Configure Google Cloud Provider
provider "google" {
  project = "freshivores-431302"
  region  = "europe-west1"
  credentials = "${file("gcp.json")}"
}