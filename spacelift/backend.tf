terraform {
  backend "s3" {
    bucket         = "natera-dvtl815-spacelift-poc-state"
    key            = "spacelift/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "dvtl815-spacelift-poc-locks"
    encrypt        = true
  }
}
