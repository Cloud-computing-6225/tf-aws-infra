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

# variable "availability_zones" {
#   description = "Availability zones"
#   type        = list(string)
# }

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
