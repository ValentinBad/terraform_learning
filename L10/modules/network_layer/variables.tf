variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "env" {
  type        = string
  description = "The environment for the resources (e.g., dev, prod)"
  default     = "dev"
}
variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
  
}