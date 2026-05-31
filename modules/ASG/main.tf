# ====================================================================
# 1- إنشاء الـ Launch Template (كتالوج/نموذج السيرفرات البديلة والأحدث)
# ====================================================================
resource "aws_launch_template" "Scaled_template" {
  name_prefix   = "Scaled_launch_template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # ربط الـ Security Group بالشكل الصحيح داخل الـ Template لمنع استخدام الـ Public IP
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_sg_id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ====================================================================
# 2- إنشاء الـ Auto Scaling Group وتوزيعها على الـ Private Subnets
# ====================================================================
resource "aws_autoscaling_group" "ec2_auto_scaling" {
  name_prefix          = "asg-project-"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.private_subnet_ids

  # ربط الـ Template الجديد وتحديد جلب النسخة الأخيرة تلقائياً عند التحديث
  launch_template {
    id      = aws_launch_template.Scaled_template.id
    version = "$Latest"
  }

  # ممارسة اختيارية ممتازة: وسم السيرفرات التي تولدها الـ ASG تلقائياً
  tag {
    key                 = "Name"
    value               = "asg-scaled-instance"
    propagate_at_launch = true
  }
}

# ====================================================================
# 3- ربط مجموعة الـ Auto Scaling بالـ Target Group الخاص بالـ Load Balancer
# ====================================================================
resource "aws_autoscaling_attachment" "asg_target" {
  autoscaling_group_name = aws_autoscaling_group.ec2_auto_scaling.id
  lb_target_group_arn    = var.target_group_arn
}