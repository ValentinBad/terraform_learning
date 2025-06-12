provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "dynamic_SG_instance" {
  count         = 1
  ami           = "ami-044415bb13eee2391"
  instance_type = "t2.micro"
  tags = {
    Name = "Dynamic_SG_Instance"
  }
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id]
}

resource "aws_security_group" "dynamic_sg" {
  name        = "dynamic_sg"
  description = "Dynamic Security Group"

  dynamic "ingress" {
    for_each = [80, 443, 8080]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
