provider "aws" {
  region = "us-west-1"

}
resource "aws_s3_bucket" "bucket1" {
  bucket = var.bucket


}
