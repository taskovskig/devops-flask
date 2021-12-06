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
    bucket         = "tf-rmt-stt-fls"
    key            = "devops-flask/flask-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws.region
}

provider "helm" {
  kubernetes {
    config_path = "/tmp/output/kubeconfig-v1.21.2-k3s1.yaml"
  }
}

resource "aws_ecr_repository" "flask_app" {
  name                 = var.aws.ecr.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "helm_release" "flask_app" {
  count = var.helm_release_status ? 1 : 0

  name  = var.helm_release_name
  chart = format("./%s", var.helm_release_name)
}
