resource "aws_instance" "this" {
  count           = var.instance_count
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = var.security_group_ids

  user_data = var.user_data

  tags = {
    Name = "${var.name}-${count.index}"
  }
}

output "public_ips" {
  value = [for instance in aws_instance.this : instance.public_ip]
}
