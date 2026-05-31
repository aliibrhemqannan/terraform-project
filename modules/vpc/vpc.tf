# Create a VPC
resource "aws_vpc" "web_app_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { 
    Name = "cloudThor"
  }
}

# ========================================================
# 1. إضافة الـ Internet Gateway المفقود
# ========================================================
resource "aws_internet_gateway" "web_app_igw" {
  vpc_id = aws_vpc.web_app_vpc.id

  tags = {
    Name = "web_app_igw"
  }
}

# create public subnets in each availability zone
resource "aws_subnet" "web_app_public_subnet" {
  for_each          = var.vpc_cidr_public
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "web_app_public_subnet_${each.key}"
  }
}

# create private subnets in each availability zone
resource "aws_subnet" "web_app_private_subnet" {
  for_each          = var.vpc_cidr_private
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "web_app_private_subnet_${each.key}"
  }
}

# ========================================================
# 2. إنشاء وتحديث جداول التوجيه (Route Tables)
# ========================================================

# أ) جدول توجيه الشبكات العامة (توجيه الإنترنت إلى الـ IGW)
resource "aws_route_table" "web_app_public_route_table" {
  vpc_id = aws_vpc.web_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_app_igw.id
  }

  tags = {
    Name = "web_app_public_route_table"
  }
}

resource "aws_route_table_association" "associate_public" {
  for_each       = var.vpc_cidr_public
  subnet_id      = aws_subnet.web_app_public_subnet[each.key].id
  route_table_id = aws_route_table.web_app_public_route_table.id
}

# ب) جدول توجيه الشبكات الخاصة
resource "aws_route_table" "web_app_private_route_table" {
  vpc_id = aws_vpc.web_app_vpc.id

  tags = {
    Name = "web_app_private_route_table"
  }
}

resource "aws_route_table_association" "associate_private" {
  for_each       = var.vpc_cidr_private
  subnet_id      = aws_subnet.web_app_private_subnet[each.key].id
  route_table_id = aws_route_table.web_app_private_route_table.id
}

# ========================================================
# 3. إعداد الـ NAT Gateways والـ Elastic IPs
# ========================================================

# إنشاء Elastic IPs (EIP) للـ NAT Gateways ديناميكياً
resource "aws_eip" "nat_eip" {
  for_each   = var.vpc_cidr_public
  domain     = "vpc"
  depends_on = [aws_internet_gateway.web_app_igw] # الآن سيعمل السطر بنجاح لإننا قمنا بتعريف الـ IGW بالأعلى

  tags = {
    Name = "nat_eip_${each.key}"
  }
}

# إنشاء NAT Gateway في كل Public Subnet
resource "aws_nat_gateway" "web_app_nat_gw" {
  for_each      = var.vpc_cidr_public
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.web_app_public_subnet[each.key].id 

  tags = {
    Name = "web_app_nat_gw_${each.key}"
  }
}

# تحديث جدول توجيه الـ Private Subnets ليمر الترافيك عبر الـ NAT Gateway
resource "aws_route" "private_nat_route" {
  for_each               = var.vpc_cidr_private
  route_table_id         = aws_route_table.web_app_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.web_app_nat_gw[each.key].id
}

# ========================================================
# 4. المخرجات (Outputs)
# ========================================================
output "vpc_id" { 
  value = aws_vpc.web_app_vpc.id
}

# المخرج المخصص للشبكات الخاصة والذي يحتاجه موديول الـ EC2 كما جهزناه سابقاً
output "private_subnets_map" {
  value = { for az, subnet in aws_subnet.web_app_private_subnet : az => subnet.id }
}

# المخرج المخصص للشبكات العامة والذي يحتاجه الـ Application Load Balancer
output "public_subnets_map" {
  value = [for subnet in aws_subnet.web_app_public_subnet : subnet.id]
}