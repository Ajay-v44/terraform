
provider "aws" {
  region = "us-east-1"

}
resource "aws_instance" "instance1" {
  ami           = var.ami
  instance_type = var.instance_type
  #   subnet_id     = "subnet-0649d842b47e0005b"
  key_name = "aws_login"

}
