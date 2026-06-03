# ANÁLISIS DETALLADO DEL PROYECTO PORTCASTELLO RA6

## 1. VISIÓN GENERAL DEL PROYECTO

**Nombre:** Portcastello RA6  
**Tecnología:** Terraform (Infrastructure as Code)  
**Objetivo:** Desplegar un entorno de laboratorio educativo con infraestructura de red empresarial, incluyendo servidor Active Directory (AD) y clientes para práctica de administración de sistemas.

**Contexto Educativo:** Forma parte del curso CEFIRE sobre "IaaC en la nube: Terraform i AWS CloudFormation" - Módulo SOR (Sistema Operativo en Red).

---

## 2. ARQUITECTURA DE LA INFRAESTRUCTURA

### 2.1 Estructura General

```
┌─────────────────────────────────────────────────────────────┐
│                       AWS VPC (10.0.0.0/16)                │
│                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │  Subred Pública 1    │    │  Subred Pública 2    │     │
│  │  (10.0.1.0/24)       │    │  (10.0.2.0/24)       │     │
│  │                      │    │                      │     │
│  │  ┌────────────────┐  │    │  ┌────────────────┐  │     │
│  │  │ Win CLI (RDP)  │  │    │  │ Linux CLI(SSH) │  │     │
│  │  │ t3.medium      │  │    │  │ t3.small       │  │     │
│  │  │ 30GB           │  │    │  │ 15GB           │  │     │
│  │  └────────────────┘  │    │  └────────────────┘  │     │
│  │   EIP: público       │    │   EIP: público       │     │
│  └──────────────────────┘    └──────────────────────┘     │
│           │                            │                   │
│  ┌────────┴────────────────────────────┴─────────┐         │
│  │           IGW (Internet Gateway)              │         │
│  └─────────────────────────────────────────────┬─┘         │
│                                                │             │
│  ┌──────────────────────────────────────────────┴──┐        │
│  │           NAT Gateway (para privadas)          │        │
│  └──────────────────────────────────────────────┬──┘        │
│                                                │             │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │  Subred Privada 1    │    │  Subred Privada 2    │     │
│  │  (10.0.101.0/24)     │    │  (10.0.102.0/24)     │     │
│  │                      │    │                      │     │
│  │  ┌────────────────┐  │    │                      │     │
│  │  │  DC (Samba)    │  │    │                      │     │
│  │  │  t3.small      │  │    │                      │     │
│  │  │  20GB          │  │    │                      │     │
│  │  │  IP: .10       │  │    │                      │     │
│  │  └────────────────┘  │    │                      │     │
│  │  ┌────────────────┐  │    │                      │     │
│  │  │ Linux Server   │  │    │                      │     │
│  │  │  t3.small      │  │    │                      │     │
│  │  │  20GB          │  │    │                      │     │
│  │  │  IP: .20       │  │    │                      │     │
│  │  └────────────────┘  │    │                      │     │
│  └──────────────────────┘    └──────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. DESCRIPCIÓN POR ARCHIVOS

### 3.1 `main.tf` (Archivo Principal de Configuración)

**Propósito:** Archivo de entrada principal que orquesta la creación de la infraestructura.

**Contenido clave:**

- **Requisitos de Terraform:** Versión >= 1.3.0
- **Proveedor AWS:** Configurado para la región especificada en variables
- **Módulos utilizados:**
  - `module.network`: Crea la infraestructura de red (VPC, subredes, gateways)
  - `module.compute`: Despliega las instancias EC2 (servidores y clientes)

**Flujo de ejecución:**
```
terraform init → terraform plan → terraform apply
                    ↓
         Lee variables.tf y terraform.tfvars
                    ↓
         Ejecuta module "network"
                    ↓
         Ejecuta module "compute" (depende de outputs de network)
```

---

### 3.2 `variables.tf` (Variables Globales)

**Propósito:** Define las variables de entrada a nivel root que pueden ser personalizadas.

**Variables definidas:**

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | Región AWS donde desplegar |
| `project_name` | string | (requerido) | Prefijo para nombrar todos los recursos |
| `vpc_cidr` | string | 10.0.0.0/16 | Rango CIDR de la VPC |
| `public_subnets_cidrs` | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | CIDRs de subredes públicas |
| `private_subnets_cidrs` | list(string) | ["10.0.101.0/24", "10.0.102.0/24"] | CIDRs de subredes privadas |
| `key_name` | string | vockey | Nombre del Key Pair en AWS |
| `tipo_servidor_ad` | string | ubuntu | SO del DC: "ubuntu" o "windows" |

**Validación:** El campo `tipo_servidor_ad` incluye validación que solo acepta "ubuntu" o "windows".

---

### 3.3 `terraform.tfvars` (Valores de Variables)

**Propósito:** Asigna valores concretos a las variables definidas en `variables.tf`.

**Valores actuales:**
```hcl
project_name     = "portcastello"
tipo_servidor_ad = "ubuntu"   # Cambiar a "windows" para DC en Windows
```

**Nota:** Los demás valores usan los defaults de `variables.tf`.

---

### 3.4 `backend.tf` (Configuración del Estado)

**Propósito:** Define dónde se almacena el estado de Terraform (tfstate).

**Configuración:**
- **Backend:** S3 (Simple Storage Service)
- **Bucket:** portcastello-tfstate-202605
- **Key:** ra6/portcastello.tfstate
- **Region:** us-east-1
- **DynamoDB Table:** portcastello-tf-locks (para bloqueos distribuidos)
- **Encryption:** Habilitada

**Importancia:**
- Permite que múltiples usuarios/procesos trabajen de forma segura sobre el mismo estado
- Persiste la información de la infraestructura en la nube
- Impide corrupción del estado mediante bloqueos

---

## 4. MÓDULO DE RED (modules/network/)

### 4.1 `modules/network/variables.tf`

Define variables locales del módulo:

| Variable | Tipo | Default |
|----------|------|---------|
| `project_name` | string | (heredado del root) |
| `aws_region` | string | us-east-1 |
| `vpc_cidr` | string | 10.0.0.0/16 |
| `public_subnets_cidrs` | list(string) | 2 subredes |
| `private_subnets_cidrs` | list(string) | 2 subredes |

### 4.2 `modules/network/main.tf` (Infraestructura de Red)

**Componentes creados:**

**A) VPC (Virtual Private Cloud)**
- CIDR: 10.0.0.0/16
- DNS habilitado
- Aislamiento de red desde internet

**B) Subredes Públicas**
- 2 subredes en diferentes zonas de disponibilidad (HA)
- CIDRs: 10.0.1.0/24, 10.0.2.0/24
- Auto-asignación de IPs públicas habilitada
- Alcanzables desde internet

**C) Subredes Privadas**
- 2 subredes en diferentes zonas de disponibilidad (HA)
- CIDRs: 10.0.101.0/24, 10.0.102.0/24
- NO asignan IPs públicas directas
- Salida a internet a través de NAT Gateway

**D) Internet Gateway (IGW)**
- Proporciona acceso a internet para subredes públicas
- Ruta 0.0.0.0/0 → IGW

**E) NAT Gateway**
- Ubicado en subred pública
- Proporciona salida a internet para subredes privadas
- Usa Elastic IP (IP pública fija)
- Ruta 0.0.0.0/0 → NAT Gateway

**F) Tablas de Rutas**
- `rt-public`: Enruta todo hacia IGW
- `rt-private`: Enruta todo hacia NAT Gateway
- Asociaciones de tablas: vinculan subredes con sus tablas

**Código Terraform detallado:**

```hcl
# Datos dinámicos de zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Subredes públicas (con count para crear 2)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true  # <-- Asigna IP pública automáticamente
}

# Subredes privadas (con count para crear 2)
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# EIP para NAT
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # En la primera subred pública
  depends_on    = [aws_internet_gateway.main]
}

# Tabla de rutas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Tabla de rutas privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# Asociaciones (vinculan subredes con sus tablas de rutas)
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### 4.3 `modules/network/outputs.tf`

**Exporta valores clave** para que el módulo compute los use:

```hcl
output "vpc_id" → ID de la VPC
output "public_subnet_ids" → IDs de las subredes públicas [subnet1, subnet2]
output "private_subnet_ids" → IDs de las subredes privadas [subnet1, subnet2]
output "nat_gateway_ip" → IP pública del NAT Gateway
```



---

## 5. MÓDULO DE CÓMPUTO (modules/compute/)

### 5.1 `modules/compute/variables.tf`

Define parámetros de entrada específicos para las instancias:

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `project_name` | string | (requerido) | Prefijo para nombrar recursos |
| `vpc_id` | string | (requerido) | ID de la VPC (de network) |
| `vpc_cidr` | string | (requerido) | CIDR de la VPC |
| `public_subnet_ids` | list(string) | (requerido) | IDs de subredes públicas |
| `private_subnet_ids` | list(string) | (requerido) | IDs de subredes privadas |
| `private_subnets_cidrs` | list(string) | (requerido) | CIDRs de subredes privadas |
| `key_name` | string | vockey | Nombre del Key Pair de AWS |
| `tipo_servidor_ad` | string | ubuntu | SO del DC: "ubuntu" o "windows" |

### 5.2 `modules/compute/main.tf` (Instancias EC2)

**A) Búsqueda Dinámica de AMIs (Amazon Machine Images)**

```hcl
# AMI Ubuntu 22.04 más reciente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# AMI Windows Server 2019 más reciente
data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}
```

**Ventaja:** Siempre utiliza la AMI más reciente sin actualizar código.

**B) Variables Locales (lógica condicional)**

```hcl
locals {
  dc_es_windows = var.tipo_servidor_ad == "windows"
  
  # Selección dinámica según OS del DC
  dc_ami    = local.dc_es_windows ? data.aws_ami.windows_2019.id : data.aws_ami.ubuntu.id
  dc_type   = local.dc_es_windows ? "t3.medium" : "t3.small"
  dc_disk   = local.dc_es_windows ? 50 : 20
  dc_script = local.dc_es_windows ? file("${path.root}/scripts/init_windows_dc.ps1") : file("${path.root}/scripts/init_server_dc.sh")
}
```

**Lógica:**
- Si `tipo_servidor_ad = "windows"`: DC con Windows Server 2019, t3.medium, 50GB, script PowerShell
- Si `tipo_servidor_ad = "ubuntu"`: DC con Ubuntu 22.04, t3.small, 20GB, script bash

**C) Instancias EC2 Desplegadas**

#### 5.2.1 Controlador de Dominio (DC)

```hcl
resource "aws_instance" "dc" {
  ami                    = local.dc_ami
  instance_type          = local.dc_type
  subnet_id              = var.private_subnet_ids[0]      # Subred privada 1
  key_name               = var.key_name
  private_ip             = cidrhost(var.private_subnets_cidrs[0], 10)  # IP fija: .10
  vpc_security_group_ids = [aws_security_group.dc.id]
  user_data              = local.dc_script                # Script de inicialización
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
```

**Características:**
- **Ubicación:** Subred privada (sin IP pública directa)
- **IP Fija:** 10.0.101.10 (configurada con `cidrhost()`)
- **Rol:** Controlador de dominio (Samba en Ubuntu o AD en Windows)
- **Seguridad:** Security Group específico para DC
- **User Data:** Script que instala y configura Samba/AD
- **Tags:** Facilita identificación en AWS Console

#### 5.2.2 Servidor Linux Miembro

```hcl
resource "aws_instance" "linux_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_ids[0]      # Subred privada 1
  key_name               = var.key_name
  private_ip             = cidrhost(var.private_subnets_cidrs[0], 20)  # IP fija: .20
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
```

**Características:**
- **Ubicación:** Subred privada
- **IP Fija:** 10.0.101.20
- **Rol:** Servidor miembro del dominio (comparte archivos)
- **SO:** Ubuntu 22.04
- **Script:** Instala Samba como cliente de dominio

#### 5.2.3 Cliente Windows

```hcl
resource "aws_instance" "win_cli" {
  ami                         = data.aws_ami.windows_2019.id
  instance_type               = "t3.medium"
  subnet_id                   = var.public_subnet_ids[0]  # Subred pública
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

# Elastic IP para cliente Windows
resource "aws_eip" "win_cli" {
  instance   = aws_instance.win_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.win_cli]
  tags       = { Name = "${var.project_name}-eip-win-cli" }
}
```

**Características:**
- **Ubicación:** Subred pública
- **IP Pública:** Elastic IP (fija)
- **Acceso:** RDP desde cualquier lugar (puerto 3389)
- **Rol:** Cliente unido al dominio
- **Script:** Instala cliente Windows, une al dominio

#### 5.2.4 Cliente Linux

```hcl
resource "aws_instance" "linux_cli" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_ids[1]  # Subred pública 2
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

# Elastic IP para cliente Linux
resource "aws_eip" "linux_cli" {
  instance   = aws_instance.linux_cli.id
  domain     = "vpc"
  depends_on = [aws_instance.linux_cli]
  tags       = { Name = "${var.project_name}-eip-linux-cli" }
}
```

**Características:**
- **Ubicación:** Subred pública 2
- **IP Pública:** Elastic IP (fija)
- **Acceso:** SSH desde cualquier lugar (puerto 22)
- **Rol:** Cliente unido al dominio
- **Script:** Instala cliente Linux, une al dominio

### 5.3 `modules/compute/security.tf` (Políticas de Seguridad)

Define 4 Security Groups (Firewalls virtuales):

#### 5.3.1 Security Group para DC

```hcl
resource "aws_security_group" "dc" {
  name        = "${var.project_name}-sg-dc"
  description = "AD/Samba DC - trafico interno VPC"
  vpc_id      = var.vpc_id
```

**Reglas de Entrada (Ingress):**
- **SSH (22):** TCP desde VPC (para acceso remoto)
- **DNS (53):** TCP/UDP desde VPC
- **Kerberos (88):** TCP desde VPC (autenticación)
- **RPC (135):** TCP desde VPC
- **NetBIOS (139):** TCP desde VPC
- **LDAP (389):** TCP desde VPC (consultas de directorio)
- **SMB (445):** TCP desde VPC (compartición de archivos)
- **LDAPS (636):** TCP desde VPC (LDAP seguro)
- **Global Catalog (3268-3269):** TCP desde VPC
- **RDP (3389):** TCP desde VPC

**Regla de Salida (Egress):**
- **Todos:** 0.0.0.0/0 (acceso sin restricciones a internet)

**Restricción:** Solo tráfico desde dentro de la VPC (seguridad)

#### 5.3.2 Security Group para Servidor Linux

```hcl
resource "aws_security_group" "linux_server" {
  name        = "${var.project_name}-sg-linux-server"
  description = "Servidor Samba - trafico interno VPC"
```

**Reglas de Entrada:**
- **SSH (22):** TCP desde VPC
- **SMB (445):** TCP desde VPC (compartición de archivos)
- **NFS (2049):** TCP desde VPC (acceso a red)

**Regla de Salida:**
- **Todos:** 0.0.0.0/0

#### 5.3.3 Security Group para Cliente Windows

```hcl
resource "aws_security_group" "win_cli" {
  name        = "${var.project_name}-sg-win-cli"
  description = "Cliente Windows - RDP publico"
```

**Reglas de Entrada:**
- **RDP (3389):** TCP desde 0.0.0.0/0 (ACCESO PÚBLICO - alumnos)
- **Todo:** desde VPC (para comunicarse con DC y servidor Linux)

**Importante:** RDP abierto a internet para que alumnos se conecten

#### 5.3.4 Security Group para Cliente Linux

```hcl
resource "aws_security_group" "linux_cli" {
  name        = "${var.project_name}-sg-linux-cli"
  description = "Cliente Linux - SSH publico"
```

**Reglas de Entrada:**
- **SSH (22):** TCP desde 0.0.0.0/0 (ACCESO PÚBLICO - alumnos)
- **Todo:** desde VPC (para comunicarse con DC y servidor Linux)

**Importante:** SSH abierto a internet para que alumnos se conecten

### 5.4 `modules/compute/outputs.tf`

```hcl
output "dc_ip_privada"         → 10.0.101.10 (configure como DNS)
output "linux_server_ip_privada" → 10.0.101.20
output "win_cli_public_ip"      → IP pública del cliente Windows
output "linux_cli_public_ip"    → IP pública del cliente Linux
```



---

## 6. ARCHIVOS RAÍZ (Root Module)

### 6.1 `outputs.tf`

Exporta información clave para que el usuario pueda acceder a la infraestructura:

```hcl
output "ip_dc_privada" → IP privada del DC (configurar como DNS)
output "ip_publica_win_cli" → IP pública del cliente Windows
output "ip_publica_linux_cli" → IP pública del cliente Linux
output "comando_rdp" → Comando directo: mstsc /v:<IP>
output "comando_ssh" → Comando directo: ssh -i labsuser.pem ubuntu@<IP>
```

**Utilidad:** Después de `terraform apply`, muestra directamente los comandos para conectarse.

### 6.2 `backend.tf`

Almacena el estado en S3 de forma centralizada:

```hcl
backend "s3" {
  bucket         = "portcastello-tfstate-202605"
  key            = "ra6/portcastello.tfstate"
  region         = "us-east-1"
  dynamodb_table = "portcastello-tf-locks"
  encrypt        = true
}
```

**Ventajas:**
- ✅ Estado compartido entre equipos
- ✅ Bloqueos con DynamoDB (evita conflictos)
- ✅ Encriptación en reposo
- ✅ Histórico de cambios

---

## 7. CONCEPTOS TERRAFORM UTILIZADOS

### 7.1 Módulos

**Definición:** Carpetas autónomas con su propio código Terraform.

**Ventajas:**
- Reutilización (network se podría usar en otro proyecto)
- Organización (separación de responsabilidades)
- Escalabilidad (fácil añadir más módulos)

### 7.2 Variables (Input Variables)

**Tipos utilizados:**
- `string`: texto
- `list(string)`: lista de textos
- Con validaciones integradas (`contains()`, `validation {}`)

**Jerarquía:**
```
Defaults (variables.tf)
    ↓
Override por terraform.tfvars
    ↓
Override por -var flag
```

### 7.3 Locals (Variables Locales)

Cálculos internos que no son parámetros de entrada:

```hcl
locals {
  dc_es_windows = var.tipo_servidor_ad == "windows"
  dc_ami = local.dc_es_windows ? windows_ami : ubuntu_ami
}
```

Útil para lógica condicional compleja.

### 7.4 Data Sources

Consultan información de AWS sin crear recursos:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  ...
}
```

Obtiene la AMI más reciente dinámicamente.

### 7.5 Outputs (Valores de Salida)

Exportan información:
- Entre módulos (module.network.vpc_id)
- Al usuario (terraform output)
- A otros sistemas (CI/CD)

### 7.6 Count

Crea múltiples recursos con un bucle:

```hcl
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)  # Crea 2 subredes
  ...
}
```

### 7.7 Splat Syntax

Extrae atributos de múltiples recursos:

```hcl
aws_subnet.public[*].id  # [subnet-1, subnet-2]
```

### 7.8 Depends_on (Dependencias Explícitas)

Asegura orden de creación:

```hcl
resource "aws_nat_gateway" "main" {
  depends_on = [aws_internet_gateway.main]
}
```

---

## 8. FLUJO DE EJECUCIÓN

### 8.1 Paso 1: terraform init

```bash
terraform init
```

**Qué hace:**
- Descarga provider AWS
- Configura backend S3
- Inicializa módulos

**Output:**
```
Terraform has been successfully initialized!
Backend initialized and locked
Modules loaded
```

### 8.2 Paso 2: terraform plan

```bash
terraform plan
```

**Qué hace:**
- Analiza configuración
- Conecta a AWS
- Calcula qué recursos crear/modificar/destruir
- Genera un plan

**Output:**
```
Plan: 30 to add, 0 to change, 0 to destroy
- aws_vpc.main
- aws_subnet.public[0]
- aws_subnet.public[1]
- ...
```

### 8.3 Paso 3: terraform apply

```bash
terraform apply
```

**Qué hace:**
- Ejecuta el plan
- Crea recursos en AWS
- Actualiza el estado en S3

**Output:**
```
Apply complete! Resources: 30 added

Outputs:
ip_dc_privada = "10.0.101.10"
comando_rdp = "mstsc /v:54.123.45.67"
comando_ssh = "ssh -i labsuser.pem ubuntu@54.123.45.68"
```

---

## 9. CASOS DE USO EDUCATIVOS

Con esta infraestructura, los estudiantes pueden practicar:

### 9.1 Administración de Active Directory
- Crear usuarios y grupos en el DC
- Usar Group Policies (GPO)
- Autenticación Kerberos

### 9.2 Gestión de Dominios
- Unir clientes al dominio
- Troubleshooting de conectividad DNS
- Resolución de nombres LDAP

### 9.3 Compartición de Recursos
- Compartir carpetas SMB
- Acceso de lectura/escritura basado en permisos
- Montaje de NFS

### 9.4 Infraestructura en la Nube
- Entender VPC y subredes
- Configurar Security Groups
- Trabajar con Terraform
- Automatización con IaC

---

## 10. FLUJO LÓGICO DE LA INFRAESTRUCTURA

```
Usuario (internet)
    │
    ├─→ SSH (puerto 22) ─→ Cliente Linux (subred pública)
    │                      IP privada: 10.0.101.x → DC
    │
    └─→ RDP (puerto 3389) ─→ Cliente Windows (subred pública)
                            IP privada: 10.0.101.x → DC

DC (Controlador de Dominio)
    ├─ Autoridad de autenticación
    ├─ Servidor DNS (puerto 53)
    ├─ Servidor LDAP (puerto 389)
    └─ Almacén central de credenciales

Servidor Linux (Samba)
    ├─ Cliente del dominio
    ├─ Compartidor SMB (puerto 445)
    └─ Almacenamiento de archivos

NAT Gateway (Salida a internet)
    └─ Permite que servidores privados salgan a internet
```

---

## 11. RESUMEN TÉCNICO

| Aspecto | Detalle |
|---------|---------|
| **Cloud Provider** | AWS (Amazon Web Services) |
| **IaC Tool** | Terraform 1.3+ |
| **Zona** | us-east-1 (configurable) |
| **Instancias** | 5 EC2 (t3.small, t3.medium) |
| **Sistemas Operativos** | Ubuntu 22.04, Windows Server 2019 |
| **Servicios** | Samba/AD, DNS, LDAP, SMB, SSH, RDP |
| **Almacenamiento** | 20-50 GB por instancia (gp3) |
| **Networking** | 1 VPC, 4 subredes, IGW, NAT GW, 4 SG |
| **Seguridad** | IP privadas, Elastic IPs, SG granulares |
| **Estado** | S3 + DynamoDB |
| **Costo Estimado** | ~$30-50 USD/mes (si no está en AWS Academy) |

---

## 12. ESTRUCTURA DE DIRECTORIOS

```
portcastello-ra6/
├── main.tf                    # Orquestación principal
├── variables.tf               # Variables globales
├── terraform.tfvars           # Valores concretos
├── outputs.tf                 # Exports de info
├── backend.tf                 # Configuración del estado
├── .terraform.lock.hcl        # Versions lockfile
├── tfplan                     # Plan binario
├── modules/
│   ├── network/
│   │   ├── main.tf            # VPC, subredes, gateways
│   │   ├── variables.tf       # Variables del módulo
│   │   └── outputs.tf         # Exports del módulo
│   └── compute/
│       ├── main.tf            # EC2 instances
│       ├── variables.tf       # Variables del módulo
│       ├── security.tf        # Security Groups
│       └── outputs.tf         # Exports del módulo
└── scripts/
    ├── init_windows_dc.ps1    # Setup Windows DC
    ├── init_server_dc.sh      # Setup Samba DC
    ├── init_win_cli.ps1       # Setup Windows client
    ├── init_linux_cli.sh      # Setup Linux client
    └── init_linux_server.sh   # Setup Linux server
```

