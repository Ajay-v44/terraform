terraform {
  backend "s3" {
    bucket         = "remotebuccket-tf-ajay"
    region         = "us-east-1"
    key            = "ajay/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
