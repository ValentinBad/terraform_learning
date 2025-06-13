provider "aws" {
  region = "eu-west-2"

}

data "aws_vpc" "vpc_id" {
  tags = {
    Name = "dev"
  }
}

data "aws_availability_zones" "available_zones" {

}

data "aws_caller_identity" "current" {

}

data "aws_region" "current" {}


resource "aws_subnet" "public_subnet" {
  vpc_id            = data.aws_vpc.vpc_id.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  tags = {
    Name    = "PublicSubnet ${data.aws_availability_zones.available_zones.names[0]}"
    Account = "Account-${data.aws_caller_identity.current.account_id}"
  }

}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = data.aws_vpc.vpc_id.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  tags = {
    Name    = "PublicSubnet2 ${data.aws_availability_zones.available_zones.names[1]}"
    Account = "Account-${data.aws_caller_identity.current.account_id}"
  }

}

