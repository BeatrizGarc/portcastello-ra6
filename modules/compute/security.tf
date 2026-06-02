# ── SG Controlador de Dominio (solo tráfico interno VPC) ─────────────
resource "aws_security_group" "dc" {
  name        = "${var.project_name}-sg-dc"
  description = "AD/Samba DC - trafico interno VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH"
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
    description = "Kerberos"
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
    description = "LDAP"
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
    description = "GC"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "RDP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-dc"
  }
}

# ── SG Servidor Linux miembro (solo tráfico interno VPC) ─────────────
resource "aws_security_group" "linux_server" {
  name        = "${var.project_name}-sg-linux-server"
  description = "Servidor Samba - trafico interno VPC"
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

  tags = {
    Name = "${var.project_name}-sg-linux-server"
  }
}

# ── SG Cliente Windows (RDP público para alumnos) ─────────────────────
resource "aws_security_group" "win_cli" {
  name        = "${var.project_name}-sg-win-cli"
  description = "Cliente Windows - RDP publico"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RDP"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-win-cli"
  }
}

# ── SG Cliente Linux (SSH público para alumnos) ───────────────────────
resource "aws_security_group" "linux_cli" {
  name        = "${var.project_name}-sg-linux-cli"
  description = "Cliente Linux - SSH publico"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-linux-cli"
  }
}
