module "vpc" {
  source = "../modules/vpc"
}


module "alb" {
  source = "../modules/ALB"
  vpc_id_from_outside = module.vpc.vpc_id
  web_sg_id = module.ec2.web_sg_id
  public_subnet_ids   = module.vpc.public_subnets_map

}

module "ec2" {
  source = "../modules/ec2"

  # تمرير الـ VPC ID
  vpc_id_from_outside = module.vpc.vpc_id

  # تمرير الـ Subnets الخريطة بالكامل ديناميكياً
  private_subnet_ids = module.vpc.private_subnets_map
}




# 3. موديول الـ Auto Scaling الجديد والربط السحري بين الموديولات
module "autoscaling" {
  source = "../modules/ASG"

  # ربطه بموديول الـ VPC للحصول على الـ Security Group والـ Subnets
  web_sg_id          = module.ec2.web_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids_list

  # ربطه بموديول الـ ALB لكي يسجل السيرفرات الجديدة داخل الـ Load Balancer تلقائياً
  target_group_arn   = module.alb.target_group_arn
}


module "database" {
  source              = "../modules/database"
  
  # تمرير الـ VPC ID وقائمة الـ Subnets الخاصة من موديول الـ VPC
  vpc_id_from_outside = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids_list
  
  # تمرير الـ Security Group الخاص بالسيرفرات لمنحها صلاحية الدخول لقاعدة البيانات
  web_sg_id           = module.ec2.web_sg_id
}