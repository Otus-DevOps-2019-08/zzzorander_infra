terraform {
  backend "gcs" {
    bucket = "storage-bucket-zedzzorander"
    prefix = "prod"
  }
}
