# 1- Security group for ALB
resource "aws_security_group" "ALBSG" {
  name        = "ALBSG"
  description = "security group for alb"
  vpc_id      = var.vpc_id_from_outside # مصحح: يقرأ من الموديول الخارجي

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # أفضل ممارسة: السماح بالخروج للوصول للسيرفرات الخلفية والـ Health Check
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2- Create ALB
resource "aws_lb" "project_alb" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  
  # مصحح: يقرأ قائمة الشبكات العامة ديناميكياً بالكامل القادمة من موديول الـ VPC
  subnets            = var.public_subnet_ids 
}

# 3- Create ALB target group باسم webTG حسب الصورة المطلوبة سابقاً
resource "aws_lb_target_group" "project_tg" {
  name     = "webTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id_from_outside # مصحح: يقرأ المتغير القادم من الخارج بدلاً من المورد المحلي المفقود

  health_check {
    enabled             = true
    port                = "80"
    protocol            = "HTTP"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 4- Create listener لربط منفذ 80 بالـ Target Group
resource "aws_lb_listener" "listener_lb" {
  load_balancer_arn = aws_lb.project_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_tg.arn
  }
}



output "target_group_arn" {
  value = aws_lb_target_group.project_tg.arn
}