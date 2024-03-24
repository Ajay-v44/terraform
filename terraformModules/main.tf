provider "aws" {
  region = "us-east-1"
}
module "ec2_instance" {
    source="./modules/en2_instance"
    ami="ami-080e1f13689e07408"
    instance_type = "t2.micro"

}

module "aws_s3_bucket" {
  source = "./modules/s3"
  bucket = "mybucket-tf"


}
