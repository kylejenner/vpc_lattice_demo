terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
     helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
} 
provider "aws" {
  region  = "us-west-2"
  alias   = "network"
}
provider "aws" {
  region  = "us-west-2"
  alias   = "consumer1"
}
provider "aws" {
  region  = "us-west-2"
  alias   = "consumer2"
}
provider "aws" {
  region  = "us-west-2"
  alias   = "consumer3"
}