variable "region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "public_subnet_1_cidr" {
  type = string

}
variable "public_subnet_2_cidr" {
  type = string
}
variable "private_subnet_1_cidr" {
  type =string
}
variable "private_subnet_2_cidr" {
  type =string
}
variable "private_subnet_3_cidr" {
  type =string
}
variable "private_subnet_4_cidr" {
  type =string
}
variable "private_subnet_5_cidr" {
  type =string
}
variable "private_subnet_6_cidr" {
  type =string
}
variable "availability_zone-1a" {
  type = string
}
variable "availability_zone-1b" {
  type = string
}
variable "ami" {
  type=string
}
variable "key_name" {
  type=string
}
variable "instance_type" {
  type = string
}
variable "db_password" {
  type = string
}
variable "db_instance_type" {
  type=string
}
variable "db_username" {
  type=string
}
variable "instance_class" {
  type=string
}
# public_subnet_1_cidr ="172.20.1.0/24"
# public_subnet_2_cidr ="172.20.2.0/24"
# private_subnet_1_cidr = "172.20.3.0/24"
# private_subnet_2_cidr = "172.20.4.0/24"
# private_subnet_3_cidr = "172.20.5.0/24"
# private_subnet_4_cidr = "172.20.6.0/24"
# private_subnet_5_cidr = "172.20.7.0/24"
# private_subnet_6_cidr = "172.20.8.0/24"
# availability_zone-1a = "us-east-1a"
# availability_zone-1b = "us-east-1b"
# ami = "ami-04b70fa74e45c3917"
# key-name = "us-east-1"
# instance-type = "t2.micro"