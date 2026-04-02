terraform {
  backend "gcs" {
    bucket = "terraform-state-1672439705281"
    prefix = "terraform/state" # acts as a folder path within the bucket
  }
}
