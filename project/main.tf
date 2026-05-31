module "vpc" {
  source = "../modules/vpc"
}

module "ec2" {
  source = "../modules/ec2"

  # تمرير الـ VPC ID
  vpc_id_from_outside = module.vpc.vpc_id

  # تمرير الـ Subnets الخريطة بالكامل ديناميكياً
  private_subnet_ids = module.vpc.private_subnets_map
}