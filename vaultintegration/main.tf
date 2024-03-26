provider "aws" {
  region = "us-east-1"

}
provider "vault" {
  address          = "http://44.223.24.213:8400"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = " 1143a3b3-4e66-1433-e3f4-34ad907a3078"
      secret_id = " bbdaf0df-2d7d-1790-c270-8f7f899290ba"
    }
  }
}
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}

resource "aws_instance" "name" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  tags = {
    secret = data.vault_kv_secret_v2.example.data["username"]
  }

}
