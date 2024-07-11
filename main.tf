module "vpc" {
  source = "./modules/vpc"
}

module "security_group" {
  source     = "./modules/security-group"
  vpc_id     = module.vpc.vpc_id
}

module "master" {
  source              = "./modules/ec2"
  ami                 = "ami-0c55b159cbfafe1f0"
  instance_type       = "t2.medium"
  subnet_id           = module.vpc.subnet_id
  security_group_ids  = [module.security_group.security_group_id]
  user_data           = file("${path.module}/scripts/master_user_data.sh")
  instance_count      = 1
  name                = "K8s-Master"
}

module "workers" {
  source              = "./modules/ec2"
  ami                 = "ami-0c55b159cbfafe1f0"
  instance_type       = "t2.micro"
  subnet_id           = module.vpc.subnet_id
  security_group_ids  = [module.security_group.security_group_id]
  user_data           = file("${path.module}/scripts/worker_user_data.sh")
  instance_count      = 2
  name                = "K8s-Worker"
}

output "master_ip" {
  value = module.master.public_ips
}

output "worker_ips" {
  value = module.workers.public_ips
}
