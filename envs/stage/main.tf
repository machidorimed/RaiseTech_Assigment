# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# backend
terraform {
  backend "s3" {
    bucket = "aws-study-marube23-backet"
    key    = "stage/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# moduleの利用
module "network" {
  # moduleの位置
  source = "../../modules/network"
  # 変数へ値の設定
  my_env          = var.my_env
  vpc_cidr_block  = var.vpc_cidr_block
  pubA_cidr_block = var.pubA_cidr_block
  priA_cidr_block = var.priA_cidr_block
  pubC_cidr_block = var.pubC_cidr_block
  priC_cidr_block = var.priC_cidr_block
}

module "compute" {
  # moduleの位置
  source = "../../modules/compute"
  # 変数へ値の設定
  my_env = var.my_env
  vpc_id = module.network.vpc_id
  public_subnet_ids = [
    module.network.pub_sub_a_id,
    module.network.pub_sub_c_id
  ]
  public_subnet_id = module.network.pub_sub_a_id
  my_ip            = var.my_ip
  my_ami           = var.my_ami
  my_instance_type = var.my_instance_type
  #  key_name         = var.key_name
}

module "database" {
  # moduleの位置
  source = "../../modules/database"
  # 変数へ値の設定
  subnet_ids = [
    module.network.pri_sub_a_id,
    module.network.pri_sub_c_id
  ]
  vpc_id                   = module.network.vpc_id
  ec2_sg_id                = module.compute.ec2_sg_id
  my_env                   = var.my_env
  my_engine                = var.my_engine
  my_engine_version        = var.my_engine_version
  database_master_name     = var.database_master_name
  database_name            = var.database_name
  my_instance_class        = var.my_instance_class
  database_master_password = var.database_master_password
}

module "monitoring" {
  # moduleの位置
  source = "../../modules/monitoring"
  # 変数へ値の設定
  my_env = var.my_env
  #instance_id = module.compute.instance_id
  #my_email    = var.my_email
}

#module "security" {
# moduleの位置
#  source = "../../modules/security"
# 変数へ値の設定
#  my_env             = var.my_env
#  allow_ip_addresses = var.allow_ip_addresses
#  alb_arn            = module.compute.alb_arn
#  log_group_arn      = module.monitoring.waf_log_group_arn
#}
