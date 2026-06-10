# EXPLICACIÓN DETALLADA DE CARPETAS Y CONTENIDO

## 📂 Estructura General del Proyecto

```
portcastello-ra6/
├── 📄 ARCHIVOS RAÍZ (configuración principal)
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── backend.tf
│   └── .terraform.lock.hcl
│
├── 📁 .terraform/ (GENERADA AUTOMÁTICAMENTE)
│   ├── modules/
│   ├── providers/
│   └── terraform.tfstate
│
├── 📁 modules/ (CÓDIGO REUTILIZABLE)
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── (sin archivos de estado)
│   │
│   └── compute/
│       ├── main.tf
│       ├── security.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── (sin archivos de estado)
│
├── 📁 scripts/ (AUTOMATIZACIÓN)
│   ├── init_windows_dc.ps1
│   ├── init_server_dc.sh
│   ├── init_win_cli.ps1
│   ├── init_linux_cli.sh
│   └── init_linux_server.sh
│
└── 📁 .kiro/ (OPCIONAL - Configuración de Kiro IDE)
    └── (metadata del proyecto)
```

---

## 📄 SECCIÓN 1: ARCHIVOS RAÍZ (Nivel Superior)

Estos archivos están en la carpeta principal de `portcastello-ra6/`.

### 1.1 `main.tf` - Archivo Principal de Orquestación

**¿Qué es?**  
El archivo más importante. Orquesta todo el proyecto.

**¿Qué contiene?**
```
┌─────────────────────────────────────┐
│  CONFIGURACIÓN DE TERRAFORM         │
├─────────────────────────────────────┤
│ • required_version (>= 1.3.0)       │
│ • required_providers                │
│   └─ aws (>= 4.44.0)                │
│                                     │
├─────────────────────────────────────┤
│  PROVEEDOR AWS                      │
├─────────────────────────────────────┤
│ provider "aws" {                    │
│   region = var.aws_region           │
│ }                                   │
│                                     │
├─────────────────────────────────────┤
│  MÓDULOS (LLAMADAS)                 │
├─────────────────────────────────────┤
│ module "network" {                  │
│   source = "./modules/network"      │
│   variables...                      │
│ }                                   │
│                                     │
│ module "compute" {                  │
│   source = "./modules/compute"      │
│   variables...                      │
│ }                                   │
└─────────────────────────────────────┘
```

**¿Cuántas líneas?**  
~30-40 líneas (muy limpio)

**¿Por qué tan corto?**  
Porque toda la lógica está en los módulos. Este archivo solo coordina.

**¿Cómo se usa?**
```bash
terraform init    # Lee este archivo
terraform plan    # Ejecuta main.tf
terraform apply   # Aplica lo que main.tf dice
```

---

### 1.2 `variables.tf` - Variables Globales

**¿Qué es?**  
Define los parámetros de entrada que puedes personalizar.

**¿Qué contiene?**
```hcl
variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombrar todos los recursos"
  type        = string
  # ⚠️ NO TIENE DEFAULT - es obligatorio proporcionar
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tipo_servidor_ad" {
  description = "SO del DC: 'ubuntu' o 'windows'"
  type        = string
  default     = "ubuntu"
  
  validation {
    condition     = contains(["ubuntu", "windows"], var.tipo_servidor_ad)
    error_message = "Solo 'ubuntu' o 'windows' permitidos"
  }
}

# + más variables (vpc_cidrs, key_name, etc.)
```

**Variables que contiene:**
| Variable | Tipo | Default | Significado |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | Región AWS donde desplegar |
| `project_name` | string | (requerido) | Prefijo para recursos |
| `vpc_cidr` | string | 10.0.0.0/16 | Rango CIDR principal |
| `public_subnets_cidrs` | list | [10.0.1.0/24, 10.0.2.0/24] | Subredes públicas |
| `private_subnets_cidrs` | list | [10.0.101.0/24, 10.0.102.0/24] | Subredes privadas |
| `key_name` | string | vockey | Key Pair en AWS |
| `tipo_servidor_ad` | string | ubuntu | "ubuntu" o "windows" |

**¿Cómo se usa?**
```bash
# Opción 1: Valores en terraform.tfvars (recomendado)
terraform apply

# Opción 2: Flag en línea de comandos
terraform apply -var="project_name=mi-proyecto"

# Opción 3: Variable de entorno
export TF_VAR_project_name="mi-proyecto"
terraform apply
```

**¿Cuántas líneas?**  
~50-60 líneas

---

### 1.3 `terraform.tfvars` - Valores Concretos

**¿Qué es?**  
Aquí colocas los VALORES ESPECÍFICOS para tu proyecto.

**¿Qué contiene?**
```hcl
project_name     = "portcastello"
tipo_servidor_ad = "ubuntu"   # Cambiar a "windows" si quieres
# aws_region usa default (us-east-1)
# vpc_cidr usa default (10.0.0.0/16)
# etc.
```

**¿Cuántos valores necesito?**  
Solo los que quieras cambiar. El resto usan defaults.

**¿Dónde se proporciona?**
```
variables.tf (definición) ← terraform.tfvars (valores) ← terraform apply
```

**¿Cuántas líneas?**  
~3-5 líneas (muy simple)

**⚠️ IMPORTANTE:**
- Nunca incluyas secrets aquí
- Nunca hagas commit si contiene passwords
- Es específico de tu entorno

---

### 1.4 `outputs.tf` - Información de Salida

**¿Qué es?**  
Define qué información se muestra después de `terraform apply`.

**¿Qué contiene?**
```hcl
output "ip_dc_privada" {
  description = "IP privada del DC — usar como DNS"
  value       = module.compute.dc_ip_privada
}

output "ip_publica_win_cli" {
  description = "IP pública del cliente Windows (RDP)"
  value       = module.compute.win_cli_public_ip
}

output "ip_publica_linux_cli" {
  description = "IP pública del cliente Linux (SSH)"
  value       = module.compute.linux_cli_public_ip
}

output "comando_rdp" {
  description = "Comando directo para RDP"
  value       = "mstsc /v:${module.compute.win_cli_public_ip}"
}

output "comando_ssh" {
  description = "Comando directo para SSH"
  value       = "ssh -i labsuser.pem ubuntu@${module.compute.linux_cli_public_ip}"
}
```

**¿Qué ves al ejecutar `terraform output`?**
```
ip_dc_privada = "10.0.101.10"
ip_publica_win_cli = "54.123.45.67"
ip_publica_linux_cli = "54.123.45.68"
comando_rdp = "mstsc /v:54.123.45.67"
comando_ssh = "ssh -i labsuser.pem ubuntu@54.123.45.68"
```

**¿Cuántas líneas?**  
~25-30 líneas

**¿Por qué es importante?**  
Proporciona información lista para usar (comandos copiables).

---

### 1.5 `backend.tf` - Gestión del Estado

**¿Qué es?**  
Define DÓNDE se guarda el estado de Terraform (tfstate).

**¿Qué contiene?**
```hcl
terraform {
  backend "s3" {
    bucket         = "portcastello-tfstate-202605"
    key            = "ra6/portcastello.tfstate"
    region         = "us-east-1"
    dynamodb_table = "portcastello-tf-locks"
    encrypt        = true
  }
}
```

**¿Qué hace?**
| Campo | Función |
|-------|---------|
| `bucket` | Donde se guarda el fichero .tfstate |
| `key` | Ruta dentro del bucket |
| `region` | Región del bucket |
| `dynamodb_table` | Para bloqueos distribuidos (evita conflictos) |
| `encrypt` | Encripta el estado en reposo |

**¿Por qué es importante?**
- ✅ Estado centralizado (múltiples usuarios)
- ✅ Bloqueos (evita conflictos)
- ✅ Encriptación (seguridad)
- ✅ Histórico (recuperación)

**⚠️ IMPORTANTE:**
- El bucket S3 debe existir antes
- DynamoDB table debe existir antes
- Ten credenciales AWS configuradas

**¿Cuántas líneas?**  
~10 líneas

---

### 1.6 `.terraform.lock.hcl` - Versiones Bloqueadas

**¿Qué es?**  
Archivo que bloquea las versiones exactas de providers.

**¿Qué contiene?**
```hcl
# This file is maintained automatically by "terraform init".
# Do not edit this file manually!

provider "registry.terraform.io/hashicorp/aws" {
  version     = "6.47.0"
  constraints = ">= 4.44.0"
  hashes = [
    "h1:...",
    "zh:...",
  ]
}
```

**¿Por qué es importante?**
- ✅ Reproducibilidad (mismo código = mismo resultado)
- ✅ Evita sorpresas (provider updates automáticos)
- ✅ Compatible con Git (commit this file)

**¿Cuándo se genera?**
- Se crea automáticamente al hacer `terraform init`
- NO lo edites manualmente
- DEBES hacer commit en Git

**¿Cuántas líneas?**  
~30-50 líneas (generadas automáticamente)

---

### 1.7 `tfplan` - Plan Binario (Opcional)

**¿Qué es?**  
Archivo binario que guarda un plan Terraform.

**¿Cómo se crea?**
```bash
terraform plan -out=tfplan
```

**¿Para qué sirve?**
```
terraform plan -out=tfplan      # Crear plan
git commit tfplan               # Guardar plan
terraform apply tfplan          # Aplicar plan guardado
```

**¿Es obligatorio?**  
No. Es opcional, pero útil para CI/CD.

**¿Cuándo incluirlo?**
- En flujos de CI/CD
- Cuando quieres guardar historial de planes
- Para review antes de apply

---

## 📁 SECCIÓN 2: CARPETA `.terraform/` (GENERADA AUTOMÁTICAMENTE)

**¿Qué es?**  
Carpeta que Terraform genera automáticamente al hacer `terraform init`.

**¿Qué contiene?**
```
.terraform/
├── modules/
│   └── modules.json (referencias a módulos locales)
│
└── providers/
    └── registry.terraform.io/
        └── hashicorp/
            └── aws/
                └── 6.47.0/
                    └── linux_amd64/
                        ├── terraform-provider-aws_v6.47.0_x5
                        └── LICENSE.txt
```

**¿Qué hace?**
- Descarga los providers (AWS plugin)
- Gestiona módulos
- Almacena configuración local

**⚠️ IMPORTANTE:**
- **NO hacer commit** en Git
- Incluir en `.gitignore`
- Se regenera automáticamente con `terraform init`
- Ocupa ~300-500 MB (no se versiona)

**¿Cuándo se regenera?**
```bash
rm -r .terraform          # Eliminar
terraform init            # Regenera automáticamente
```

---

## 📁 SECCIÓN 3: CARPETA `modules/` (CÓDIGO REUTILIZABLE)

La carpeta `modules/` contiene dos módulos: `network` y `compute`.

### 3.1 `modules/network/` - Infraestructura de Red

**¿Qué es?**  
Módulo que crea TODA la infraestructura de red en AWS.

**¿Qué archivos contiene?**

#### 3.1.1 `modules/network/main.tf`

**¿Qué crea?** (30-40 recursos de red)

```
┌──────────────────────────────────────┐
│  AWS VPC (Virtual Private Cloud)     │
├──────────────────────────────────────┤
│ • 1 VPC                              │
│ • 2 Subredes Públicas                │
│ • 2 Subredes Privadas                │
│ • 1 Internet Gateway (IGW)           │
│ • 1 NAT Gateway                      │
│ • 1 Elastic IP para NAT              │
│ • 1 Tabla de rutas pública           │
│ • 1 Tabla de rutas privada           │
│ • 4 Asociaciones de tabla/subred     │
│                                      │
│ TOTAL: ~15 recursos                  │
└──────────────────────────────────────┘
```

**Ejemplo de código:**
```hcl
# VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # 10.0.0.0/16
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project_name}-vpc" }
}

# Subredes Públicas (con count para crear 2)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidrs)  # 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true  # <-- importante
  tags = { Name = "${var.project_name}-public-${count.index + 1}" }
}

# ... más recursos ...
```

**¿Cuántas líneas?**  
~120-150 líneas

**¿Qué variables necesita?**
```hcl
project_name
aws_region
vpc_cidr
public_subnets_cidrs
private_subnets_cidrs
```

---

#### 3.1.2 `modules/network/variables.tf`

**¿Qué contiene?**  
Las variables ESPECÍFICAS del módulo network.

```hcl
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
```

**¿Cuántas líneas?**  
~20-30 líneas

---

#### 3.1.3 `modules/network/outputs.tf`

**¿Qué exporta?**  
Información que el módulo compute necesita.

```hcl
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
  # Usado por: module.compute.source
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
  # Resultado: ["subnet-xxx", "subnet-yyy"]
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
  # Resultado: ["subnet-aaa", "subnet-bbb"]
}

output "nat_gateway_ip" {
  description = "IP pública del NAT Gateway"
  value       = aws_eip.nat.public_ip
}
```

**¿Cuántas líneas?**  
~20 líneas

**¿Por qué es importante?**  
El módulo compute NECESITA estos valores (vpc_id, subnet_ids).

---

### 3.2 `modules/compute/` - Instancias EC2

**¿Qué es?**  
Módulo que crea TODAS las instancias EC2 y security groups.

**¿Qué archivos contiene?**

#### 3.2.1 `modules/compute/main.tf`

**¿Qué crea?** (5 instancias + data sources)

```
┌──────────────────────────────────────┐
│  DATA SOURCES (búsqueda de AMIs)     │
├──────────────────────────────────────┤
│ • data "aws_ami" "ubuntu" (dinámica) │
│ • data "aws_ami" "windows" (dinámica)│
│                                      │
├──────────────────────────────────────┤
│  LOCALS (variables internas)         │
├──────────────────────────────────────┤
│ • dc_es_windows (condicional)        │
│ • dc_ami (IF windows THEN... ELSE...)│
│ • dc_type (t3.medium vs t3.small)    │
│ • dc_disk (50GB vs 20GB)             │
│ • dc_script (PowerShell vs Bash)     │
│                                      │
├──────────────────────────────────────┤
│  INSTANCIAS EC2 (5)                  │
├──────────────────────────────────────┤
│ 1. aws_instance "dc" (Controlador)   │
│ 2. aws_instance "linux_server"       │
│ 3. aws_instance "win_cli"            │
│ 4. aws_instance "linux_cli"          │
│ + Elastic IPs para clientes          │
│                                      │
│ TOTAL: ~15 recursos                  │
└──────────────────────────────────────┘
```

**Ejemplo de código:**
```hcl
# Data source: AMI Ubuntu más reciente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Locals: Lógica condicional
locals {
  dc_es_windows = var.tipo_servidor_ad == "windows"
  dc_ami        = local.dc_es_windows ? data.aws_ami.windows_2019.id : data.aws_ami.ubuntu.id
  dc_type       = local.dc_es_windows ? "t3.medium" : "t3.small"
}

# Instancia DC
resource "aws_instance" "dc" {
  ami                    = local.dc_ami
  instance_type          = local.dc_type
  subnet_id              = var.private_subnet_ids[0]
  private_ip             = cidrhost(var.private_subnets_cidrs[0], 10)
  vpc_security_group_ids = [aws_security_group.dc.id]
  user_data              = file("${path.root}/scripts/init_${var.tipo_servidor_ad}_dc.sh")
  
  root_block_device {
    volume_size = local.dc_disk
    volume_type = "gp3"
  }
  
  tags = {
    Name = "${var.project_name}-dc"
    Role = "DomainController"
  }
}

# ... más instancias ...
```

**¿Cuántas líneas?**  
~200-250 líneas

---

#### 3.2.2 `modules/compute/security.tf`

**¿Qué crea?**  
Los 4 Security Groups (firewalls).

```
┌──────────────────────────────────────┐
│  SECURITY GROUPS (4)                 │
├──────────────────────────────────────┤
│ 1. SG DC                             │
│    ├─ SSH 22 (desde VPC)             │
│    ├─ DNS 53 (TCP/UDP desde VPC)     │
│    ├─ Kerberos 88                    │
│    ├─ LDAP 389, SMB 445              │
│    ├─ RDP 3389                       │
│    └─ Egress abierto                 │
│                                      │
│ 2. SG Servidor Linux                 │
│    ├─ SSH 22 (desde VPC)             │
│    ├─ SMB 445, NFS 2049              │
│    └─ Egress abierto                 │
│                                      │
│ 3. SG Cliente Windows                │
│    ├─ RDP 3389 (0.0.0.0/0) ← PÚBLICO│
│    ├─ Todo desde VPC                 │
│    └─ Egress abierto                 │
│                                      │
│ 4. SG Cliente Linux                  │
│    ├─ SSH 22 (0.0.0.0/0) ← PÚBLICO  │
│    ├─ Todo desde VPC                 │
│    └─ Egress abierto                 │
└──────────────────────────────────────┘
```

**Ejemplo de código:**
```hcl
resource "aws_security_group" "dc" {
  name        = "${var.project_name}-sg-dc"
  description = "AD/Samba DC - tráfico interno VPC"
  vpc_id      = var.vpc_id
  
  # Ingress: SSH desde VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  # Ingress: DNS
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  # ... más puertos ...
  
  # Egress: Todo permitido
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ... más security groups ...
```

**¿Cuántas líneas?**  
~200 líneas

---

#### 3.2.3 `modules/compute/variables.tf`

**¿Qué contiene?**  
Variables específicas del módulo compute.

```hcl
variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "private_subnets_cidrs" { type = list(string) }
variable "key_name" { type = string; default = "vockey" }
variable "tipo_servidor_ad" { type = string; default = "ubuntu" }
```

**¿Cuántas líneas?**  
~15 líneas

---

#### 3.2.4 `modules/compute/outputs.tf`

**¿Qué exporta?**

```hcl
output "dc_ip_privada" {
  description = "IP privada del DC (configurar como DNS)"
  value       = aws_instance.dc.private_ip
}

output "linux_server_ip_privada" {
  description = "IP privada del servidor Linux"
  value       = aws_instance.linux_server.private_ip
}

output "win_cli_public_ip" {
  description = "IP pública del cliente Windows"
  value       = aws_eip.win_cli.public_ip
}

output "linux_cli_public_ip" {
  description = "IP pública del cliente Linux"
  value       = aws_eip.linux_cli.public_ip
}
```

**¿Cuántas líneas?**  
~20 líneas

---

## 📁 SECCIÓN 4: CARPETA `scripts/` - Automatización

**¿Qué es?**  
Scripts que se ejecutan automáticamente en las instancias al crearse.

**¿Qué archivos contiene?** (5 scripts)

### 4.1 `scripts/init_windows_dc.ps1`

**¿Qué es?**  
Script PowerShell que configura un Controlador de Dominio en Windows.

**¿Qué hace?**
```powershell
# 1. Instala características
Install-WindowsFeature AD-Domain-Services

# 2. Configura el dominio
Install-ADDSForest -DomainName "portcastello.local"

# 3. Crea usuarios iniciales
New-ADUser -Name "profesor" -AccountPassword ...

# 4. Configuración de red
Set-NetIPAddress -AddressFamily IPv4 ...

# + más configuración
```

**¿Cuándo se ejecuta?**  
Cuando `terraform apply` crea la instancia Windows DC.

**¿Cuántas líneas?**  
~50-100 líneas

---

### 4.2 `scripts/init_server_dc.sh`

**¿Qué es?**  
Script Bash que configura un Controlador de Dominio en Ubuntu (Samba).

**¿Qué hace?**
```bash
#!/bin/bash
set -e

# 1. Actualizar sistema
apt-get update
apt-get upgrade -y

# 2. Instalar Samba
apt-get install -y samba samba-dsdb-modules samba-vfs-modules

# 3. Configurar Samba como DC
samba-tool domain provision --realm=PORTCASTELLO.LOCAL ...

# 4. Iniciar servicios
systemctl start samba
systemctl enable samba

# + más configuración
```

**¿Cuándo se ejecuta?**  
Cuando `terraform apply` crea la instancia Ubuntu DC.

**¿Cuántas líneas?**  
~80-150 líneas

---

### 4.3 `scripts/init_win_cli.ps1`

**¿Qué es?**  
Script que configura un cliente Windows.

**¿Qué hace?**
```powershell
# 1. Configura red
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.101.10

# 2. Intenta unirse al dominio
Add-Computer -DomainName "portcastello.local" -Credential ...

# 3. Reinicia
Restart-Computer -Force
```

**¿Cuántas líneas?**  
~30-50 líneas

---

### 4.4 `scripts/init_linux_cli.sh`

**¿Qué es?**  
Script que configura un cliente Linux.

**¿Qué hace?**
```bash
#!/bin/bash

# 1. Actualizar DNS
echo "nameserver 10.0.101.10" > /etc/resolv.conf

# 2. Instalar cliente Samba
apt-get install -y samba-client winbind libnss-winbind

# 3. Configurar SSSD
apt-get install -y sssd sssd-tools

# 4. Unirse al dominio
realm join -U administrator PORTCASTELLO.LOCAL

# + configuración final
```

**¿Cuántas líneas?**  
~40-80 líneas

---

### 4.5 `scripts/init_linux_server.sh`

**¿Qué es?**  
Script que configura un servidor Linux (miembro del dominio).

**¿Qué hace?**
```bash
#!/bin/bash

# 1. Actualizar sistema
apt-get update && apt-get upgrade -y

# 2. Instalar Samba como cliente
apt-get install -y samba samba-common-bin smbclient

# 3. Configurar DNS
echo "nameserver 10.0.101.10" >> /etc/resolv.conf

# 4. Unirse al dominio
realm join -U administrator PORTCASTELLO.LOCAL

# 5. Crear shares
mkdir -p /srv/shares
chmod 777 /srv/shares

# + configuración final
```

**¿Cuántas líneas?**  
~50-100 líneas

---

## 📊 Tabla Resumen: Archivos vs Propósito

| Carpeta/Archivo | Líneas | Propósito | Responsable |
|---|---|---|---|
| **main.tf** | 30-40 | Orquestación | Estudiante |
| **variables.tf** | 50-60 | Parámetros globales | Estudiante |
| **terraform.tfvars** | 3-5 | Valores personalizados | Estudiante |
| **outputs.tf** | 25-30 | Info de salida | Estudiante |
| **backend.tf** | 10 | State en S3 | Estudiante |
| **modules/network/main.tf** | 120-150 | VPC, subnets, gateways | Estudiante |
| **modules/network/variables.tf** | 20-30 | Variables network | Estudiante |
| **modules/network/outputs.tf** | 20 | Exports network | Estudiante |
| **modules/compute/main.tf** | 200-250 | EC2, AMIs, instancias | Estudiante |
| **modules/compute/security.tf** | 200 | Security Groups | Estudiante |
| **modules/compute/variables.tf** | 15 | Variables compute | Estudiante |
| **modules/compute/outputs.tf** | 20 | Exports compute | Estudiante |
| **scripts/init_windows_dc.ps1** | 50-100 | Setup DC Windows | Estudiante |
| **scripts/init_server_dc.sh** | 80-150 | Setup DC Samba | Estudiante |
| **scripts/init_win_cli.ps1** | 30-50 | Setup Win Client | Estudiante |
| **scripts/init_linux_cli.sh** | 40-80 | Setup Linux Client | Estudiante |
| **scripts/init_linux_server.sh** | 50-100 | Setup Linux Server | Estudiante |
| | | | |
| **TOTAL LÍNEAS** | **~1000-1500** | Proyecto completo | Estudiante |

---

## 🔄 Flujo de Ejecución

### 1. Lectura de Archivos
```
terraform init
  ↓
  Lee: main.tf, variables.tf, backend.tf
  ↓
  Descarga .terraform/providers/
```

### 2. Validación
```
terraform validate
  ↓
  Lee main.tf
  Valida sintaxis HCL
  Verifica módulos
```

### 3. Planning
```
terraform plan
  ↓
  Lee: main.tf, variables.tf, terraform.tfvars
  Carga valores de terraform.tfvars
  Ejecuta main.tf
  Llama: module.network (lee modules/network/*)
  Llama: module.compute (lee modules/compute/*)
  Conecta a AWS
  Calcula cambios
  Genera tfplan
```

### 4. Application
```
terraform apply
  ↓
  Lee tfplan
  Crea recursos en este orden:
  
  1. VPC (modules/network/main.tf)
  2. Subredes (modules/network/main.tf)
  3. IGW, NAT (modules/network/main.tf)
  4. Rutas (modules/network/main.tf)
  5. Security Groups (modules/compute/security.tf)
  6. Instancias EC2 (modules/compute/main.tf)
  7. Elastic IPs (modules/compute/main.tf)
  
  Para cada instancia:
  ├─ Ejecuta script (init_*.ps1 o init_*.sh)
  └─ Instancia automáticamente configurada
  
  Actualiza: backend.tf (state en S3)
  Muestra: outputs.tf (IPs, comandos)
```

---

## 📝 Relaciones Entre Archivos

```
main.tf (orquestador)
├─→ variables.tf (parámetros)
├─→ terraform.tfvars (valores)
├─→ backend.tf (estado)
├─→ outputs.tf (salida)
│
├─→ module.network:
│   ├─→ modules/network/main.tf
│   ├─→ modules/network/variables.tf
│   ├─→ modules/network/outputs.tf
│   ↓ exporta (vpc_id, subnet_ids)
│
└─→ module.compute (depende de network):
    ├─→ modules/compute/main.tf (usa outputs de network)
    ├─→ modules/compute/security.tf
    ├─→ modules/compute/variables.tf
    ├─→ modules/compute/outputs.tf
    ↓ user_data ejecuta:
    └─→ scripts/init_*.sh o *.ps1
        (configuran instancias automáticamente)
```

---

## 🎯 Resumen Rápido

**ARCHIVOS RAÍZ** (~130-160 líneas):
- Orquestación (main.tf)
- Variables (variables.tf)
- Valores (terraform.tfvars)
- Salida (outputs.tf)
- Estado (backend.tf)

**MÓDULO NETWORK** (~160-210 líneas):
- VPC y subnets
- Gateways (IGW, NAT)
- Routing

**MÓDULO COMPUTE** (~400-550 líneas):
- Instancias EC2
- Security Groups
- Elastic IPs

**SCRIPTS** (~250-500 líneas):
- 5 scripts de automatización
- Configuración de servidores

**CARPETA .terraform/** (generada automáticamente):
- Providers (~300-500 MB)
- Módulos
- NO hacer commit

**TOTAL**: ~1000-1500 líneas de código Terraform + scripts

