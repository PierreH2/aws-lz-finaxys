terraform {
  backend "s3" {
    bucket = var.tf_state_bucket
    key    = var.tf_state_key
    region = var.tf_state_region
  }
}
