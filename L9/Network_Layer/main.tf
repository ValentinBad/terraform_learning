provider "aws" {
  region = "eu-west-2"

}

terraform {
  backend "s3" {
    bucket = "terraform-s3-test-remote-state"
    key    = "dev/network_layer/terraform.tfstate"
    region = "eu-west-2"
  }
}

#-------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.env}-vpc"
    Environment = var.env
  }
}

#-------------------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.env}-public-subnet-${count.index + 1}"
    Environment = var.env
  }
}

#-------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.env}-internet-gateway"
    Environment = var.env
  }
}
#-------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name        = "${var.env}-public-route-table"
    Environment = var.env
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}
#-------------------------------------------------------------
