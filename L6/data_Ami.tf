provider "aws" {
  region = "eu-west-2"
  
}

data "aws_ami" "latest_ubuntu"{
    owners = ["099720109477"]
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "aws_instance" "Ubuntu_Instance" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
   tags = {
    Name = "Ubuntu_Instance"
  }
}