resource "aws_security_group" "k8s" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add other required ports (e.g., 10250, 30000-32767 for NodePorts)
}

output "security_group_id" {
  value = aws_security_group.k8s.id
}
