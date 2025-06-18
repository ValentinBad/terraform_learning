data "aws_availability_zones" "available_zones" {

}

#=============================================================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr


  tags = {
    Name        = "${var.env}-vpc"
    Environment = var.env
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.env}-igw"
    Environment = var.env
  }
}

#-------------------------------------------------------------
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available_zones.names, count.index)

  tags = {
    Name        = "${var.env}-public-subnet-${count.index + 1}"
    Environment = var.env
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available_zones.names, count.index)

  tags = {
    Name        = "${var.env}-private-subnet-${count.index + 1}"
    Environment = var.env
  }
}

#-------------------------------------------------------------

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
resource "aws_route_table_association" "public_subnet_association" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
#-------------------------------------------------------------

resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name        = "${var.env}-nat-eip"
    Environment = var.env
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name        = "${var.env}-nat-gateway"
    Environment = var.env
  }
}

#-------------------------------------------------------------

resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
}
resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnets)

  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_table[*].id, count.index)
}

#-------------------------------------------------------------
