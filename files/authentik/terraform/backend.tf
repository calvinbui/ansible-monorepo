terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "authentik"

    # minio specific
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
