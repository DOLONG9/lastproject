terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.18.0"
    }
  }
}
provider "aws" {
  alias = "kr"
  region = "ap-northeast-2" # 서울 리전
  shared_credentials_files = ["~/.aws/credentials"]
}

provider "aws" {
  alias = "jp"
  region = "ap-northeast-1" # 도쿄 리전
  shared_credentials_files = ["~/.aws/credentials"]
}
