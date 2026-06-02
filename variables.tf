variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombrar todos los recursos"
  type        = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidrs" {
  description = "CIDRs de las subredes públicas (clientes)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidrs" {
  description = "CIDRs de las subredes privadas (DC y servidores)"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "key_name" {
  description = "Nombre del Key Pair en AWS (vockey en AWS Academy)"
  type        = string
  default     = "vockey"
}

variable "tipo_servidor_ad" {
  description = "SO del Controlador de Dominio: 'ubuntu' o 'windows'"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "windows"], var.tipo_servidor_ad)
    error_message = "El valor debe ser 'ubuntu' o 'windows'."
  }
}
