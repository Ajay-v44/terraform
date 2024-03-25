provider "aws" {
  region = "us-east-1"

}
variable "ami" {
  description = "ami value"

}
variable "instance_type" {
  description = "value of instance type"
 

}
resource "aws_instance" "instance1" {
  ami           = var.ami
  instance_type = var.instance_type

}
