provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg1" {
  name = "sg1-tf"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "myec2" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name      = "ajay-demo"
  security_groups = [aws_security_group.sg1.name]

  tags = {
    Name = "my-ec2"
  }
}
