variable "region_name" {
   type = string
   default = "ap-south-1"
}

variable "my_ami" {
   type = string
   default = "ami-0c614dee691cbbf37"
}

variable "vpc_id" {
  type = string
  default = "vpc-0c33cdc23aa09385b"
}

variable "inst_type" {
   type = string
   default = "t2.micro"
}
