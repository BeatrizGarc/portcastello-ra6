terraform {
  backend "s3" {
    bucket         = "portcastello-tfstate-202605"
    key            = "ra6/portcastello.tfstate"
    region         = "us-east-1"
    dynamodb_table = "portcastello-tf-locks"
    encrypt        = true
  }
}
