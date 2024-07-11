variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "user_data" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "name" {
  type = string
}
