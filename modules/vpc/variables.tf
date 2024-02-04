variable "region" {
    type = string
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}
variable "enable_dns_support" {
    type = bool
    default = true  
}
variable "enable_dns_hostnames" {
    type = bool
    default = true  
}
variable "app_name" {
    type = string
}
variable "app_environment" {
    type = string
}
variable "availability_zones" {
    type = list(string)
}
variable "public_subnet_cidrs" {
    type = list(string)
    default = [ "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24" ]
}
variable "map_public_ip_on_launch" {
    type = bool
    default = true
}
variable "private_subnet_cidrs" {
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}