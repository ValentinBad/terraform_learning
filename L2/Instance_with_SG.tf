provider "aws" {
  region = "us-west-2"

}

resource "aws_instance" "Ubunu_Instance_with_SG" {
  count         = 1
  ami           = "ami-0a605bc2ef5707a18"
  instance_type = "t2.micro"
  tags = {
    Name = "Ubuntu_Instance_with_SG"
  }
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
}

resource "aws_security_group" "instance_sg" {
  name        = "SG_for_Ubuntu_Instance"
  description = "Security group for Ubuntu instance"
  ingress {
    from_port   = 80
    to_port     = 80
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
