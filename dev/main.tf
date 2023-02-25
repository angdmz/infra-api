module "network" {
  source = "./network"
}

module "database" {
  source = "./database"
  network_id = module.network.dev_network_id
  subnet_id = module.network.dev_subnet_az1_id
  runtime_security_id = module.runtime.runtime_security_id
  subnet_az1_id = module.network.dev_subnet_az1_id
  subnet_az2_id = module.network.dev_subnet_az2_id
  subnet_az3_id = module.network.dev_subnet_az3_id
}

module "runtime" {
  source = "./runtime"
  network_id = module.network.dev_network_id
  subnet_id = module.network.dev_subnet_az1_id
}