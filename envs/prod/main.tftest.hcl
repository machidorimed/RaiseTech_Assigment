# test 用の参照値
variables {
  database_master_password = "dummy-password"
  #  my_email                 = "test@example.com"
}

# ------------------------------------------------------------#
#  Network Test
# ------------------------------------------------------------#
run "network_VPC_test" {
  # plan を実施し、その結果を見て Test  
  command = plan

  assert {
    condition     = module.network.vpc_cidr_block == "10.0.0.0/16"
    error_message = "VPCのCIDRが不一致"
  }
}

run "network_Subnet_test" {
  command = plan

  assert {
    condition     = module.network.public_subnets.a_cidr == "10.0.1.0/24"
    error_message = "パブリックサブネットAのCIDRが不一致"
  }

  assert {
    condition     = module.network.private_subnets.a_cidr == "10.0.2.0/24"
    error_message = "プライベートサブネットAのCIDRが不一致"
  }

  assert {
    condition     = module.network.public_subnets.c_cidr == "10.0.3.0/24"
    error_message = "パブリックサブネットCのCIDRが不一致"
  }

  assert {
    condition     = module.network.private_subnets.c_cidr == "10.0.4.0/24"
    error_message = "プライベートサブネットCのCIDRが不一致"
  }
}

# ------------------------------------------------------------#
#  Compute Test
# ------------------------------------------------------------#
run "compute_EC2_test" {
  command = plan

  assert {
    condition     = module.compute.ec2_instance_type == "t3.micro"
    error_message = "EC2のinstance_typeが不一致"
  }
}

# ------------------------------------------------------------#
#  Database Test
# ------------------------------------------------------------#
run "database_RDS_test" {
  command = plan

  assert {
    condition     = module.database.rds_instance_summary.engine == "mysql"
    error_message = "RDSのengineが不一致"
  }

  assert {
    condition     = module.database.rds_instance_summary.engine_version == "8.0.41"
    error_message = "RDSのengine_versionが不一致"
  }

  assert {
    condition     = module.database.rds_instance_summary.instance_class == "db.t4g.micro"
    error_message = "RDSのinstance_classが不一致"
  }
}
