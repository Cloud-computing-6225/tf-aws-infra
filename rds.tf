resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Database security group"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_sg.id]
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_db_subnet_group" "csye6225_db_subnet_group" {
  name        = "csye6225-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids  = aws_subnet.private_subnets[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "csye6225-db-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for MySQL"

  tags = {
    Name = "${var.project_name}-db-parameter-group"
  }
}

resource "aws_db_instance" "csye6225_db" {
  identifier             = "csye6225"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  engine_version         = "8.0.39"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.csye6225_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = var.db_user
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  db_name                = var.db_name

  tags = {
    Name = "${var.project_name}-db-instance"
  }
}
