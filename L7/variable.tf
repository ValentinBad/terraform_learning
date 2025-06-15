variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"

}

variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "sg_ingress_ports" {
  description = "List of ports for security group ingress rules"
  type        = list(number)
  default     = [80, 443, 8080]
  
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Development"
    Project     = "Terraform Example"
  }
}