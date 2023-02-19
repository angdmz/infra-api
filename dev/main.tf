module "network" {
  source = "./network"
}

module "database" {
  source = "./database"
  network_id = module.network.dev_network_id
  subnet_id = module.network.dev_subnet_id
}

module "runtime" {
  source = "./runtime"
  network_id = module.network.dev_network_id
  subnet_id = module.network.dev_subnet_id
}