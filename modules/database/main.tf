# 1- Database subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds-db-subnet"
  
  # مصحح ديناميكياً: يستقبل قائمة الـ Private Subnets بالكامل من موديول الـ VPC
  subnet_ids = var.private_subnet_ids
}

# 2- Create the database Security Group
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "security group for RDS database"
  vpc_id      = var.vpc_id_from_outside # مصحح ديناميكياً

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    
    # مصحح ديناميكياً: لا يسمح بالدخول إلا للسيرفرات التي تحمل هذا الـ Security Group
    security_groups = [var.web_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3- Create database instance
resource "aws_db_instance" "rds_instance" {
  allocated_storage      = var.allocated_storage
  identifier             = "rds-terraform"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  tags = {
    Name = "ExampleRDSServerInstance"
  }
}