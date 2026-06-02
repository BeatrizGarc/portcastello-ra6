#!/bin/bash
# fix_hcl.sh — Corrige errores de sintaxis HCL (sin punto y coma)
VERDE='\033[0;32m'; AZUL='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${VERDE}  ✔ $1${NC}"; }
info() { echo -e "${AZUL}  → $1${NC}"; }

info "Corrigiendo archivos HCL..."

# ── modules/network/variables.tf ─────────────────────────────────────
cat > modules/network/variables.tf << 'EOF'
variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}
EOF
ok "modules/network/variables.tf"

# ── modules/compute/variables.tf ─────────────────────────────────────
cat > modules/compute/variables.tf << 'EOF'
variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_subnets_cidrs" {
  type = list(string)
}

variable "tipo_servidor_ad" {
  type    = string
  default = "ubuntu"
}
EOF
ok "modules/compute/variables.tf"

# ── modules/compute/main.tf ──────────────────────────────────────────
cat > modules/compute/main.tf << 'EOF'
# ── AMIs dinámicas ───────────────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

# ── Selección dinámica según tipo_servidor_ad ─────────────────────────
locals {
  dc_es_windows = var.tipo_servidor_ad == "windows"
  dc_ami        = local.dc_es_windows ? data.aws_ami.windows_2019.id : data.aws_ami.ubuntu.id
  dc_type       = local.dc_es_windows ? "t3.medium" : "t3.small"
  dc_disk       = local.dc_es_windows ? 50 : 20
  dc_script     = local.dc_es_windows ? file("${path.root}/scripts/init_windows_dc.ps1") : file("${path.root}/scripts/init_server_dc.sh")
}

# ── DC: Controlador de Dominio (subred privada, IP fija .10) ──────────
resource "aws_instance" "dc" {
  ami           = local.dc_ami
  instance_type = local.dc_type
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.key_name
  private_ip    = cidrhost(var.private_subnets_cidrs[0], 10)

  vpc_security_group_ids = [aws_security_group.dc.id]
  user_data              = local.dc_script

  root_block_device {
    volume_size = local.dc_disk
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.project_name}-dc"
    Modulo = "SOR-RA6"
    Rol    = "DomainController"
    SO     = var.tipo_servidor_ad
  }
}

# ── Servidor Linux miembro (subred privada, IP fija .20) ──────────────
resource "aws_instance" "linux_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.key_name
  private_ip    = cidrhost(var.private_subnets_cidrs[0], 20)

  vpc_security_group_ids = [aws_security_group.linux_server.id]
  user_data              = file("${path.root}/scripts/init_linux_server.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.project_name}-linux-server"
    Modulo = "SOR-RA6"
    Rol    = "FileServer"
  }
}

# ── Cliente Windows (subred pública, RDP desde exterior) ──────────────
resource "aws_instance" "win_cli" {
  ami                         = data.aws_ami.windows_2019.id
  instance_type               = "t3.medium"
  subnet_id                   = var.public_subnet_ids[0]
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.win_cli.id]
  user_data              = file("${path.root}/scripts/init_win_cli.ps1")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.project_name}-win-cli"
    Modulo = "SOR-RA6"
    Rol    = "ClienteWindows"
  }
}

# ── Cliente Linux (subred pública, SSH desde exterior) ────────────────
resource "aws_instance" "linux_cli" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_ids[1]
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.linux_cli.id]
  user_data              = file("${path.root}/scripts/init_linux_cli.sh")

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.project_name}-linux-cli"
    Modulo = "SOR-RA6"
    Rol    = "ClienteLinux"
  }
}

# ── Elastic IPs (IPs fijas entre sesiones) ────────────────────────────
resource "aws_eip" "win_cli" {
  instance   = aws_instance.win_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.win_cli]

  tags = { Name = "${var.project_name}-eip-win-cli" }
}

resource "aws_eip" "linux_cli" {
  instance   = aws_instance.linux_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.linux_cli]

  tags = { Name = "${var.project_name}-eip-linux-cli" }
}
EOF
ok "modules/compute/main.tf"

# ── modules/compute/security.tf ──────────────────────────────────────
cat > modules/compute/security.tf << 'EOF'
# ── SG Controlador de Dominio (solo tráfico interno VPC) ─────────────
resource "aws_security_group" "dc" {
  name        = "${var.project_name}-sg-dc"
  description = "AD/Samba DC - solo trafico interno VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH interno"
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "DNS TCP"
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "DNS UDP"
  }
  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kerberos TCP"
  }
  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kerberos UDP"
  }
  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "RPC"
  }
  ingress {
    from_port   = 139
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "NetBIOS"
  }
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "LDAP TCP"
  }
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "LDAP UDP"
  }
  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SMB"
  }
  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "LDAPS"
  }
  ingress {
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Global Catalog"
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "RDP interno"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-dc" }
}

# ── SG Servidor Linux miembro ─────────────────────────────────────────
resource "aws_security_group" "linux_server" {
  name        = "${var.project_name}-sg-linux-server"
  description = "Servidor Samba - solo trafico interno VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH"
  }
  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SMB"
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "NFS"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-linux-server" }
}

# ── SG Cliente Windows ────────────────────────────────────────────────
resource "aws_security_group" "win_cli" {
  name        = "${var.project_name}-sg-win-cli"
  description = "Cliente Windows - RDP publico"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RDP alumnos"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "VPC interna"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-win-cli" }
}

# ── SG Cliente Linux ──────────────────────────────────────────────────
resource "aws_security_group" "linux_cli" {
  name        = "${var.project_name}-sg-linux-cli"
  description = "Cliente Linux - SSH publico"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH alumnos"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "VPC interna"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-linux-cli" }
}
EOF
ok "modules/compute/security.tf"

echo ""
echo -e "${VERDE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${VERDE}║   ✔  Archivos corregidos. Continúa con:                  ║${NC}"
echo -e "${VERDE}║      terraform validate                                   ║${NC}"
echo -e "${VERDE}║      terraform plan                                       ║${NC}"
echo -e "${VERDE}║      terraform apply                                      ║${NC}"
echo -e "${VERDE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
