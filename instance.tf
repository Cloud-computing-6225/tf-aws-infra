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
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
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
  owners      = ["985539798198"]

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

resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "CloudWatchAgentInstanceProfile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# resource "aws_instance" "web_app" {
#   ami                    = data.aws_ami.custom_ami.id
#   instance_type          = var.instance_type
#   key_name               = var.key_pair_name
#   vpc_security_group_ids = [aws_security_group.web_app_sg.id]
#   subnet_id              = aws_subnet.public_subnets[0].id
#   iam_instance_profile   = aws_iam_instance_profile.cloudwatch_instance_profile.name

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   user_data = <<-EOF
#     #!/bin/bash

#     # Update package repository
#     apt-get update

#     # Install CloudWatch Agent
#     sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
#     sudo dpkg -i amazon-cloudwatch-agent.deb
#     sudo systemctl enable amazon-cloudwatch-agent

#     # Ensure the CloudWatch Agent directory exists 

#     sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/

#     # Create the directory for your web app
#     sudo mkdir -p /opt/webapp

#     # Create a .env file in /opt/webapp
#     cat <<EOL | sudo tee /opt/webapp/.env
#     DB_HOST=${aws_db_instance.csye6225_db.address}
#     DB_NAME=${var.db_name}
#     DB_USER=${var.db_user}
#     DB_PASSWORD=${var.db_password}
#     DB_PORT=3306
#     PORT=8080
#     S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}
#     AWS_REGION=${var.region}
#     project_name=${var.project_name}
#     EOL

#     # Debugging: print the created .env file
#     echo "Created .env file with the following contents:"
#     sudo cat /opt/webapp/.env

#     # Enable and start your web app service (adjust this as needed)
#     sudo systemctl daemon-reload
#     sudo systemctl enable webapp.service
#     sudo systemctl start webapp.service



#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
#     sudo systemctl restart amazon-cloudwatch-agent


#   EOF

#   disable_api_termination = false

#   tags = {
#     Name = "${var.project_name}-web-app-instance"
#   }
#   depends_on = [aws_db_instance.csye6225_db]
# }

# resource "aws_sns_topic" "user_verification_topic" {
#   name = "UserVerificationTopic"
# }


resource "aws_launch_template" "web_app_launch_template" {
  name = "webapp_launch_template"

  image_id               = data.aws_ami.custom_ami.id
  instance_type          = "t2.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Update package repository
    apt-get update

    # Install jq for parsing JSON
    apt-get update && apt-get install -y jq

     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     sudo apt-get install unzip -y
     unzip awscliv2.zip
      sudo ./aws/install

    echo "INItinating password"
    DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_password_secret.name} --query 'SecretString' --output text)


    # Install CloudWatch Agent
    sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    sudo systemctl enable amazon-cloudwatch-agent

    # Ensure the CloudWatch Agent directory exists 

    sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/

    # Create the directory for your web app
    sudo mkdir -p /opt/webapp

    # Create a .env file in /opt/webapp
    cat <<EOL | sudo tee /opt/webapp/.env
    DB_HOST=${aws_db_instance.csye6225_db.address}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_user}
    DB_PASSWORD=$DB_PASSWORD
    DB_PORT=3306
    PORT=8080
    S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}
    AWS_REGION=${var.region}
    project_name=${var.project_name}
    SNS_TOPIC_ARN=${aws_sns_topic.user_verification_topic.arn}
    EOL

    # Debugging: print the created .env file
    echo "Created .env file with the following contents:"
    sudo cat /opt/webapp/.env

    # Enable and start your web app service (adjust this as needed)
    sudo systemctl daemon-reload
    sudo systemctl enable webapp.service
    sudo systemctl start webapp.service



    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
    sudo systemctl restart amazon-cloudwatch-agent


  EOF
  )


  tags = {
    Name = "${var.project_name}-web-app-instance"
  }
}

