resource "aws_vpc" "csye6225_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "csye6225_igw" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}







