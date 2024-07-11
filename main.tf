provider "aws" {
  region = "us-west-2" # Update to your preferred region
}

terraform {
  backend "s3" {
    bucket         = "kr-statefile" # Replace with your bucket name
    key            = "backend-sf/simulator.tfstate" # Replace with your desired state file path
    region         = "us-west-2" # Update to your preferred region
    encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "kr-statefile" # Replace with a unique bucket name
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "retain"
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }
}

resource "aws_secretsmanager_secret" "ssh_key_pair" {
  name = "ssh_key_pair"
}

resource "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id     = aws_secretsmanager_secret.ssh_key_pair.id
  secret_string = file("${path.module}/id_rsa.pub")
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_key_pair.id
  secret_string = file("${path.module}/id_rsa")
}

data "aws_secretsmanager_secret" "ssh_key_pair" {
  name = aws_secretsmanager_secret.ssh_key_pair.name
}

data "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = data.aws_secretsmanager_secret.ssh_key_pair.id
}

data "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id = data.aws_secretsmanager_secret.ssh_key_pair.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = data.aws_secretsmanager_secret_version.ssh_public_key.secret_string
}

resource "aws_instance" "k8s_practice" {
  ami           = "ami-0c2272b2da6755fab" # Provided AMI ID
  instance_type = "t2.medium"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "K8sPractice"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "chmod +x minikube",
      "sudo mv minikube /usr/local/bin/",
      "minikube start --driver=none"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = data.aws_secretsmanager_secret_version.ssh_private_key.secret_string
      host        = self.public_ip
    }
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.k8s_practice.public_ip
}
