provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "FirstTFInstanceUbuntu" {
  count         = 1
  ami           = "ami-0a605bc2ef5707a18"
  instance_type = "t2.micro"
  tags = {
    Name = "FirstTFInstance"
  }
}
