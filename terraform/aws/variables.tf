variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}
variable "region" {
    default = "us-east-1"
}
variable "keyname" {
    default = "lab-box-mini"
}
variable "ami" {
    default = "ami-035be7bafff33b6b6"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
