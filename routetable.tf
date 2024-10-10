# Create a Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.csye6225_vpc.id

  # Add a route to allow internet-bound traffic
  route {
    cidr_block = "0.0.0.0/0" # Route all traffic to the Internet
    gateway_id = aws_internet_gateway.csye6225_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "Private Route Table"
  }
}
