variable "vpc_id_from_outside" {
  type        = string
  description = "هذا المتغير سيستقبل الـ ID القادم من موديول الـ VPC"
}

variable "private_subnet_ids" {
  type        = map(string)
  description = "خريطة الـ Subnet IDs الممررة من موديول الـ VPC"
}
variable "vpc_cidr_private" { 
    type = map(string)
    default = {
        "eu-north-1a" = "10.0.100.0/24" ,
        "eu-north-1b" = "10.0.200.0/24"

    }



}
