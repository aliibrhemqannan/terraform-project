variable "vpc_id_from_outside" {
  type        = string
  description = "VPC ID القادم من موديول الشبكة"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "قائمة الـ Subnet IDs العامة القادمة من موديول الشبكة"
}


variable "web_sg_id" {
  type       = string
  description = "مخرج يرسل الـ ID الخاص بـ WebSG للموديولات الأخرى"
}