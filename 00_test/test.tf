terraform{
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers{
    aws={
      source    = "hashicorp/aws"
      version   = "~> 5.0"
    }
  }
}

provider "aws"{
  region        = "ap-northeast-2"
}

resource "aws_instance" "example"{
  ami           = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  key_name      = "aws15-key"
  tags = {
    Name = "aws15-example"
    org  = "busanit"
  }
}
