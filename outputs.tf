output "master_ip" {
  value = module.master.public_ips
}

output "worker_ips" {
  value = module.workers.public_ips
}
