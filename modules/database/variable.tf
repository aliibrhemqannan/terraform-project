variable "vpc_id_from_outside" {
  type        = string
  description = "VPC ID القادم من موديول الشبكة الرئيسي"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "قائمة الـ Subnets الخاصة والقادمة من موديول الـ VPC لعمل الـ Subnet Group"
}

variable "web_sg_id" {
  type        = string
  description = "الـ Security Group ID الخاص بسيرفرات الويب للسماح لها بالاتصال بقاعدة البيانات"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "engine_version" {
  type    = string
  default = "8.0.35" # يفضل استخدام نسخة مستقرة وحديثة من MySQL 8.0
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro" # الـ db.t2.micro أصبحت قديمة جداً في AWS ويفضل استبدالها بـ t3 الأحدث والأوفر
}

variable "db_name" {
  type    = string
  default = "project_rds"
}

variable "username" {
  type    = string
  default = "ali"
}

variable "password" {
  type      = string
  default   = "P@ssw0rd1ali" # يفضل استخدام كلمة مرور قوية دائمًا
  sensitive = true
}