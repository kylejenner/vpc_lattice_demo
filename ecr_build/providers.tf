terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "us-west-2"
  alias   = "consumer2"
}
provider "aws" {
  region  = "us-west-2"
  alias   = "consumer3"
}