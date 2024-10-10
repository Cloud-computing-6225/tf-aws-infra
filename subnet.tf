# Create 3 public subnets
resource "aws_subnet" "public_subnets" {
  count = 3

  depends_on = [
    aws_vpc.csye6225_vpc,
  ]

  vpc_id     = aws_vpc.csye6225_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index] # Ensure it's count.index
  # availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public_subnet-${count.index + 1}"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create 3 private subnets
resource "aws_subnet" "private_subnets" {
  count = 3

  depends_on = [
    aws_vpc.csye6225_vpc,
  ]

  vpc_id     = aws_vpc.csye6225_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index] # Ensure it's count.index
  # availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.vpc_name}-private_subnet-${count.index + 1}"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
