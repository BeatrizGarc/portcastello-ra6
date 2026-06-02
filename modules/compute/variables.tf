variable "project_name"          { type = string }
variable "vpc_id"                { type = string }
variable "vpc_cidr"              { type = string }
variable "public_subnet_ids"     { type = list(string) }
variable "private_subnet_ids"    { type = list(string) }
variable "private_subnets_cidrs" { type = list(string) }
variable "key_name" {
  type    = string
  default = "vockey"
}
variable "tipo_servidor_ad" {
  type    = string
  default = "ubuntu"
}