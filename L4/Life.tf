provider "aws" {
  region = "eu-west-2"

}

resource "aws_eip" "StaticIP" {
  instance   = aws_instance.MyInstance.id
  depends_on = [aws_instance.MyInstance]
}



resource "aws_instance" "MyInstance" {

  ami           = "ami-044415bb13eee2391"
  instance_type = "t2.micro"
  tags = {
    Name        = "MyInstance"
    Environment = "Development"
  }
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = templatefile("script.sh.tpl", {
    instance_name = "MyInstance"
    names         = ["Alice", "Bob"]

  })

  lifecycle {
    prevent_destroy = false
  }
}



resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "My Security Group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
