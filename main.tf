provider "aws" {
  region = "us-west-2" # Update to your preferred region
}

terraform {
  backend "s3" {
    bucket         = "kr-statefile" # Use the existing bucket
    key            = "backend-sf/simulator.tfstate" # Replace with your desired state file path
    region         = "us-west-2" # Update to your preferred region
    encrypt        = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = "kr-statefile" # Use the existing bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  bucket = "kr-statefile" # Use the existing bucket

  rule {
    id     = "retain"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

data "aws_secretsmanager_secret" "ssh_public_key" {
  name = "ssh_public_key"
}

data "aws_secretsmanager_secret_version" "ssh_public_key_version" {
  secret_id = data.aws_secretsmanager_secret.ssh_public_key.id
}

locals {
  ssh_public_key = jsondecode(data.aws_secretsmanager_secret_version.ssh_public_key_version.secret_string).public_key
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = local.ssh_public_key
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
      private_key = var.ssh_private_key
      host        = self.public_ip
    }
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.k8s_practice.public_ip
}
