# not using locals for more flexibility in the future, we can use variables instead of hardcoding the CIDR blocks for public and private subnets. This allows us to easily change the CIDR blocks without modifying the code.
variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_name" {
  type    = string
  default = "project_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = {
    "eu-north-1a" = 10
    "eu-north-1b" = 20
  }
}

variable "private_subnets" {
  default = {
    "eu-north-1a" = 100
    "eu-north-1b" = 200
  }
}
variable "allowed_ports" {
  type    = list(any)
  default = ["22", "80", "443"]
}

