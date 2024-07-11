provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "kr-statefile"
    key    = "backend-sf/simulator"
    region = "us-west-2"
  }
}
