provider "aws" {
  region = var.region
}

data "aws_availability_zones" "az" {

}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

#------------------------------------------------------------
locals {
    default_tags = {
        Environment = "dev"
        SG_Ports = "List of ports for security group ingress rules ${join(",", var.sg_ingress_ports)}"
    }
}
#------------------------------------------------------------

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.az.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.az.names[1]
}

resource "aws_default_vpc" "default_vpc" {

}
#------------------------------------------------------------
resource "aws_security_group" "sg" {
  name   = "my-elb-sg"
  vpc_id = aws_default_vpc.default_vpc.id

  dynamic "ingress" {
    for_each = var.sg_ingress_ports

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
    Name = "my-elb-sg"
    Environment = local.default_tags.Environment
    SG_Ports = local.default_tags.SG_Ports
  }
}

#------------------------------------------------------------
resource "aws_launch_template" "my_template" {

  name_prefix            = "my-template-"
  image_id               = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = filebase64("${path.module}/script.sh")
  tags                   = merge( var.default_tags , {Name = "WebServer in ASG"} )
}

resource "aws_autoscaling_group" "web" {
  name                = "WebServer-Highly-Available-ASG-Ver-${aws_launch_template.my_template.latest_version}"
  min_size            = 2
  max_size            = 2
  min_elb_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  target_group_arns   = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.my_template.id
    version = aws_launch_template.my_template.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG-v${aws_launch_template.my_template.latest_version}"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}


#-------------------------------------------------------------------------------
resource "aws_lb" "web" {
  name               = "WebServer-HighlyAvailable-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}

resource "aws_lb_target_group" "web" {
  name                 = "WebServer-HighlyAvailable-TG"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_default_vpc.default_vpc.id
  deregistration_delay = 10
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

#-------------------------------------------------------------------------------
output "web_loadbalancer_url" {
  value = aws_lb.web.dns_name
}
