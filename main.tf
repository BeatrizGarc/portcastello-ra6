terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.44.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  private_subnets_cidrs = var.private_subnets_cidrs
  key_name              = var.key_name
  tipo_servidor_ad      = var.tipo_servidor_ad
}
