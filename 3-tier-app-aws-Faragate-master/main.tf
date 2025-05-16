terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "DevOps-Engineer-Shehab-Gamal"
}

module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/SecGroups"
  vpc_id = module.vpc.vpc_id
}

module "frontend" {
  source             = "./modules/FrontEnd"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  private_subnets    = module.vpc.private_subnets
  security_group_ids = module.security_groups.fe_sg_id
  alb_Sec_group      = module.security_groups.alb_sg_id
  # fe_image           = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.frontend_ecr_repo}:latest"
  fe_image = "shebogimmy/frontend:latest"
}

module "backend" {
  source             = "./modules/BackEnd"
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  security_group_ids = module.security_groups.be_sg_id
  alb_Sec_group      = module.security_groups.alb_sg_id
  # be_image           = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.backend_ecr_repo}:latest"
  be_image = "shebogimmy/backend:latest"
}

module "database" {
  source             = "./modules/DB"
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  security_group_ids = module.security_groups.db_sg_id
  DBPass             = var.DBPass
}

module "CloudFront" {
  source       = "./modules/CloudFront"
  alb_dns_name = module.frontend.fe_alb_dns_name
}
