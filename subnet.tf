# Get the available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create public subnets based on available availability zones
resource "aws_subnet" "public_subnets" {
  count = min(3, length(data.aws_availability_zones.available.names))

  depends_on = [
    aws_vpc.csye6225_vpc,
  ]

  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public_subnet-${count.index + 1}"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = min(3, length(data.aws_availability_zones.available.names))
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create private subnets based on available availability zones
resource "aws_subnet" "private_subnets" {
  count = min(3, length(data.aws_availability_zones.available.names))

  depends_on = [
    aws_vpc.csye6225_vpc,
  ]

  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private_subnet-${count.index + 1}"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = min(3, length(data.aws_availability_zones.available.names))
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
