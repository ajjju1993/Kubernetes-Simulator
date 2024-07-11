output "public_ips" {
  value = [for instance in aws_instance.this : instance.public_ip]
}
