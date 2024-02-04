# Define provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_support

  tags = {
    Name = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}


# Create public subnets
resource "aws_subnet" "public_subnet" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create route table for each public subnet
resource "aws_route_table" "public_route_table" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table-${count.index + 1}"
  }
}

# Create route table for private subnets
resource "aws_route_table" "private_route_table" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}

# Associate each public subnet with its corresponding route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = 3
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = element(aws_route_table.public_route_table[*].id, count.index)
}

# Associate each private subnet with its corresponding route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_table[*].id, count.index)
}

# Create NAT gateway for each public subnet
resource "aws_nat_gateway" "nat_gateway" {
  count = 3
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }

  depends_on = [ aws_internet_gateway.my_igw ]
}

# Create Elastic IP for each NAT gateway
resource "aws_eip" "nat_eip" {
  count = 3
  
  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
  
  depends_on = [ aws_internet_gateway.my_igw ]
}

# Create route for private subnets to use NAT gateway
resource "aws_route" "private_subnet_route" {
  count                   = 3
  route_table_id         = element(aws_route_table.private_route_table[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway[*].id, count.index)
}

