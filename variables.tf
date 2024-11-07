variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}



variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "app_port" {
  description = "Port number for the web application"
  type        = number
  default     = 8080 # you can change this to your preferred port
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # You can choose a different instance type if needed
}

variable "key_pair_name" {
  description = "Key pair for SSH access"
  type        = string
}

variable "project_name" {
  description = "Name of the project for tagging resources"
  type        = string
}
variable "allowed_ip" {
  description = "The IP address allowed to access port 8080"
  type        = string
}
variable "ami_name" {
  description = "Name of the AMI to use"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the environment"
  type        = string
}

variable "scale_up" {
  description = "The CPU usage at which system scales up"
  type        = number
}
variable "scale_down" {
  description = "The CPU usage at which system scales down"
  type        = number
}
variable "health_check_grace_period" {
  description = "The grace period "
  type        = number
}
variable "cooldown" {
  description = "Cooldown period"
  type        = number
}
variable "period" {
  description = "Period"
  type        = number
}

