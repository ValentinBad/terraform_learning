provider "aws" {
  region = "eu-west-2"

}

terraform {
  backend "s3" {
    bucket = "terraform-s3-test-remote-state"
    key    = "dev/server_layer/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-s3-test-remote-state"
    key    = "dev/network_layer/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#-------------------------------------------------------------

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform with Remote State"  >  /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name        = "${var.env}-web-server"
    Environment = var.env
  }
}

#-------------------------------------------------------------
resource "aws_security_group" "webserver" {
  name   = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = [80, 443, 8080]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.env}-webserver-sg"
    Environment = var.env
  }
}
