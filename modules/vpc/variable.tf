# not using locals for more flexibility in the future, we can use variables instead of hardcoding the CIDR blocks for public and private subnets. This allows us to easily change the CIDR blocks without modifying the code.
variable "vpc_cidr_public" { 
    type = map(string)
    default = {
        "eu-north-1a" = "10.0.10.0/24" ,
        "eu-north-1b" = "10.0.20.0/24"

    }
}

variable "vpc_cidr_private" { 
    type = map(string)
    default = {
        "eu-north-1a" = "10.0.100.0/24" ,
        "eu-north-1b" = "10.0.200.0/24"

    }



}