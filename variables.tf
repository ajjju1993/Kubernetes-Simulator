variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c2272b2da6755fab"  # Update as needed
}

variable "master_instance_type" {
  description = "Instance type for master node"
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  default     = "t2.micro"
}
