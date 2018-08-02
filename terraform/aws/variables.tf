variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}
variable "region" {
    default = "us-west-2"
}
variable "keyname" {
    default = "Vadim-us-west-2-key"
}
variable "ami" {
    default = "ami-a9d09ed1"
}
