terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    helm = {
      version = "1.3.2"
    }
    kubernetes = {
      version = ">= 1.11"
    }
  }
}

terraform {
  backend "s3" {
    bucket               = "vatbox-build-info"
    workspace_key_prefix = "terraform/tf-eks/env"
    key                  = "terraform/tf-eks"
    region               = "eu-west-1"
    dynamodb_table       = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.region
}

/*
provider "kubernetes" {
  config_path            = module.eks.kubeconfig_filename
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    config_path = module.eks.kubeconfig_filename
  }
}
*/
