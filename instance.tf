resource "aws_security_group" "web_app_sg" {
  name        = "application_sg"
  description = "Application security group for web apps"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}





# resource "aws_instance" "web_app" {
#   ami                    = data.aws_ami.custom_ami.id
#   instance_type          = var.instance_type
#   key_name               = var.key_pair_name
#   vpc_security_group_ids = [aws_security_group.web_app_sg.id]
#   subnet_id              = aws_subnet.public_subnets[0].id

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     echo "DB_HOST=${aws_db_instance.csye6225_db.endpoint}" >> /etc/environment
#     echo "DB_NAME=${var.db_name}" >> /etc/environment
#     echo "DB_USER=${var.db_user}" >> /etc/environment
#     echo "DB_PASSWORD=${var.db_password}" >> /etc/environment

#   EOF

#   disable_api_termination = false

#   tags = {
#     Name = "${var.project_name}-web-app-instance"
#   }
# }
resource "aws_instance" "web_app" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update

    # Create the directory if it doesn't exist
    sudo mkdir -p /opt/webapp

    # Create a .env file in /opt/webapp
    cat <<EOL | sudo tee /opt/webapp/.env
    DB_HOST=${aws_db_instance.csye6225_db.address}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_user}
    DB_PASSWORD=${var.db_password}
    DB_PORT=3306
    PORT=8080
    EOL

    # Debugging: print the created .env file
    echo "Created .env file with the following contents:"
    sudo cat /opt/webapp/.env

    
    sudo systemctl daemon-reload
    sudo systemctl enable webapp.service
    sudo systemctl start webapp.service
  EOF

  disable_api_termination = false

  tags = {
    Name = "${var.project_name}-web-app-instance"
  }
  depends_on = [aws_db_instance.csye6225_db]
}

