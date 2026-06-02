# ── AMIs dinámicas (siempre la versión más reciente) ─────────────────
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

  dc_ami    = local.dc_es_windows ? data.aws_ami.windows_2019.id : data.aws_ami.ubuntu.id
  dc_type   = local.dc_es_windows ? "t3.medium" : "t3.small"
  dc_disk   = local.dc_es_windows ? 50 : 20
  dc_script = local.dc_es_windows ? file("${path.root}/scripts/init_windows_dc.ps1") : file("${path.root}/scripts/init_server_dc.sh")
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
  vpc_security_group_ids      = [aws_security_group.win_cli.id]
  user_data                   = file("${path.root}/scripts/init_win_cli.ps1")
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
  vpc_security_group_ids      = [aws_security_group.linux_cli.id]
  user_data                   = file("${path.root}/scripts/init_linux_cli.sh")
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

# ── Elastic IPs para los clientes (IPs fijas entre sesiones) ─────────
resource "aws_eip" "win_cli" {
  instance   = aws_instance.win_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.win_cli]
  tags       = { Name = "${var.project_name}-eip-win-cli" }
}

resource "aws_eip" "linux_cli" {
  instance   = aws_instance.linux_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.linux_cli]
  tags       = { Name = "${var.project_name}-eip-linux-cli" }
}
