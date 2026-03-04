terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }

  # Uncomment and set backend when using remote state (e.g. S3)
  # backend "s3" {
  #   bucket = "your-terraform-state"
  #   key    = "stacks/fastschema/terraform.tfstate"
  #   region = "ap-southeast-2"
  # }
}

provider "aws" {
  # Region via AWS_REGION or provider config
}

provider "http" {}
