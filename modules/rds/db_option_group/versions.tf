terraform {
  required_version = ">= 0.12.24"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.49"
    }
  }
}
