resource "aws_vpc" "my_example_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_example_vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

# Subnets
resource "aws_subnet" "public_subnet_1a" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name        = "${var.environment}-public-1a"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_1b" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name        = "${var.environment}-public-1b"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_1a" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.21.0/24"
  tags = {
    Name        = "${var.environment}-private-1a"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_1b" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.22.0/24"
  tags = {
    Name        = "${var.environment}-private-1b"
    Environment = var.environment
  }
}

resource "aws_subnet" "database_subnet_1a" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.151.0/24"
  tags = {
    Name        = "${var.environment}-dbsubnet-1a"
    Environment = var.environment
  }
}

resource "aws_subnet" "database_subnet_1b" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.my_example_vpc.id
  cidr_block        = "10.0.152.0/24"
  tags = {
    Name        = "${var.environment}-dbsubnet-1b"
    Environment = var.environment
  }
}

# Public Route
resource "aws_route_table" "my_example_public_rt" {
  vpc_id = aws_vpc.my_example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_1a_assoc" {
  route_table_id = aws_route_table.my_example_public_rt.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

resource "aws_route_table_association" "public_1b_assoc" {
  route_table_id = aws_route_table.my_example_public_rt.id
  subnet_id      = aws_subnet.public_subnet_1b.id
}

# Private Route
resource "aws_route_table" "my_example_private_rt" {
  vpc_id = aws_vpc.my_example_vpc.id
  tags = {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_1a_assoc" {
  route_table_id = aws_route_table.my_example_private_rt.id
  subnet_id      = aws_subnet.private_subnet_1a.id
}

resource "aws_route_table_association" "private_1b_assoc" {
  route_table_id = aws_route_table.my_example_private_rt.id
  subnet_id      = aws_subnet.private_subnet_1b.id
}

# Database Subnets
resource "aws_route_table" "my_example_database_rt" {
  vpc_id = aws_vpc.my_example_vpc.id
  tags = {
    Name        = "${var.environment}-database-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "database_1a_assoc" {
  route_table_id = aws_route_table.my_example_database_rt.id
  subnet_id      = aws_subnet.database_subnet_1a.id
}

resource "aws_route_table_association" "database_1b_assoc" {
  route_table_id = aws_route_table.my_example_database_rt.id
  subnet_id      = aws_subnet.database_subnet_1b.id
}

resource "aws_eip" "nat_1a" {
  vpc = true
  tags = {
    Name        = "${var.environment}-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "my_nat_gw" {
  subnet_id     = aws_subnet.public_subnet_1a.id
  allocation_id = aws_eip.nat_1a.id
  tags = {
    Name        = "${var.environment}-natgw"
    Environment = var.environment
  }
}