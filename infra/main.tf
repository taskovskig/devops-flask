terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    /*
    helm = {
      version = ">= 2.0"
    }
    */
  }
}

terraform {
  backend "s3" {
    bucket         = "tf-stt"
    key            = "devops-flask/flask-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws.region
}

/*

provider "helm" {
  kubernetes {
    config_path = module.eks.kubeconfig_filename
  }
}
*/

resource "aws_ecr_repository" "flask_app" {
  name                 = var.aws.ecr.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
