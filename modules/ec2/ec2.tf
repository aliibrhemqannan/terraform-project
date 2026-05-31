# 1. تعريف قائمة المنافذ المطلوبة في البداية
locals {
  inbound_ports = [22, 80, 443]
}

# 2. إنشاء الـ Security Group باسم webSG
resource "aws_security_group" "web_sg" {
  name        = "webSG"
  description = "Security group for web and application tiers"
  vpc_id      = var.vpc_id_from_outside

  # استخدام الـ Dynamic Block لتوليد القواعد تلقائياً وبشكل نظيف
  dynamic "ingress" {
    for_each = local.inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }

  # السماح بكافة حركة المرور الصادرة (مهم جداً لتحميل التحديثات)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webSG"
  }
}

# 3. إنشاء سيرفرات الـ EC2 داخل الـ Private Subnets الممررة للموديول
resource "aws_instance" "web_app_instances" {
  # نجعل الحلقة تدور حول الـ Subnets القادمة من موديول الشبكة
  for_each = var.private_subnet_ids

  ami           = "ami-0754facaaac92a5bb" 
  instance_type = "t3.micro"

  # التصحيح: نأخذ الـ ID الخاص بالـ Subnet الحالية في اللفة (Iteration)
  subnet_id              = each.value
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # استدعاء ملف الـ User Data من نفس المجلد
  user_data = file("${path.module}/userdata.sh")

  # إعداد وتشفير قرص الـ EBS الأساسي لحماية البيانات الثابتة
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true 
    delete_on_termination = true
  }

  tags = {
    Name = "web_app_tier_${each.key}"
  }
}