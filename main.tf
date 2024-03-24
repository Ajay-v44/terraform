# Aws Instance creation

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0649d842b47e0005b"
  key_name      = "aws_login"
}
