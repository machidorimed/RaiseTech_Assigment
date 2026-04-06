
# 変数へ値の設定(network)
my_env          = "stage"
vpc_cidr_block  = "172.16.0.0/16"
pubA_cidr_block = "172.16.1.0/24"
priA_cidr_block = "172.16.2.0/24"
pubC_cidr_block = "172.16.3.0/24"
priC_cidr_block = "172.16.4.0/24"


# 変数へ値の設定(compute)
my_ip            = "103.5.140.188/32"
my_ami           = "ami-070d2b24928913a49"
my_instance_type = "t2.micro"
key_name         = "marube23"


# 変数へ値の設定(database)
my_engine            = "mysql"
my_engine_version    = "8.0.41"
database_master_name = "root"
database_name        = "awsstudy"
my_instance_class    = "db.t4g.micro"


# 変数へ値の設定(monitoring)


# 変数へ値の設定(security)
allow_ip_addresses = ["103.5.140.188/32"]
