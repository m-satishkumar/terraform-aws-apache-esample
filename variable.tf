variable "vpc_id" {
    type = string
}

variable "my_ip_with_cidr" {
    type = string
    description = "Provide your IP eg. 0.0.0.0/0"
}

variable "public_key" {
    type = string
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "server_name" {
    type = string
    default = "Apache Example Server"
}