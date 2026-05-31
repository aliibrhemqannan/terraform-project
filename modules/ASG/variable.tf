variable "ami_id" {
  type    = string
  default = "ami-0754facaaac92a5bb" # يمكنك تغيير الـ AMI الافتراضي حسب منطقتك
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "web_sg_id" {
  type        = string
  description = "الـ Security Group ID الخاص بالسيرفرات والقادم من موديول الـ VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "قائمة الـ Subnets الخاصة والقادمة من موديول الـ VPC"
}

variable "target_group_arn" {
  type        = string
  description = "الـ ARN الخاص بالـ Target Group والقادم من موديول الـ ALB"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 1
}