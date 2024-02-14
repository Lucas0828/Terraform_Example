variable "web_port" {
  type = number
  description = "The port will use for HTTP requests"
  default = 8080
}

variable "ssh_port"{
  type = number
  description = "The port will use for SSH"
  default = 22
}

variable "vpc_id" {
  default = "vpc-02177a7405e00959d"
}

# variable "ap-northeast-2a"{
#   default = "subnet-0f02b373f7f78e4a2"
# }

# variable "ap-northeast-2c" {
#   default = "subnet-09f682d70ced2e4a1"
# }