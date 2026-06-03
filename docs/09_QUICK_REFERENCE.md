# QUICK REFERENCE - PORTCASTELLO RA6

Una guía rápida de referencia para los estudiantes. Imprime o mantén abierta mientras trabajas.

---

## 🏗️ ARQUITECTURA EN 30 SEGUNDOS

```
┌─────────────────────────────────────────┐
│  AWS VPC (10.0.0.0/16)                  │
│                                         │
│  PUBLIC    PUBLIC       PRIVATE PRIVATE │
│  Subnet1   Subnet2      Subnet1 Subnet2 │
│  .1/24     .2/24        .101/24 .102/24 │
│  ┌─────┐  ┌─────┐       ┌────┐  ┌────┐ │
│  │WinCLI   LinCLI         DC    LinSrv  │
│  │RDP      SSH         Samba   Member   │
│  │public   public      private private  │
│  └─────┘  └─────┘       └────┘  └────┘ │
│     ↑        ↑             ↓       ↓    │
│  ← IGW ────────────────────────────→   │
│     ↑        ↑             ↓       ↓    │
│  ←── NAT ←──────────────────────────→   │
└─────────────────────────────────────────┘
```

---

## 📋 LOS 5 SERVIDORES

| Nombre | OS | IP Privada | IP Pública | Puertos | Rol |
|--------|-----|-----------|-----------|---------|-----|
| **DC** | Ubuntu/Win | 10.0.101.10 | No | DNS,LDAP,AD | Controlador Dominio |
| **LinServer** | Ubuntu | 10.0.101.20 | No | SSH,SMB,NFS | Servidor Archivos |
| **WinCLI** | Windows | Privada | Sí (EIP) | RDP | Cliente Windows |
| **LinCLI** | Ubuntu | Privada | Sí (EIP) | SSH | Cliente Linux |

---

## 🔧 COMANDOS ESENCIALES

### Inicializar Terraform
```bash
terraform init
```
Se ejecuta UNA VEZ. Descarga providers y módulos.

### Ver Plan (SIN CREAR)
```bash
terraform plan
```
Muestra qué se va a crear. Revisa antes de aplicar.

### Crear Infraestructura
```bash
terraform apply
```
Crea 30 recursos. Espera 5-10 minutos.

### Mostrar IPs y Comandos
```bash
terraform output
```
Muestra:
- IP privada del DC
- IP pública del cliente Windows (RDP)
- IP pública del cliente Linux (SSH)
- Comandos listos para usar

### Destruir Todo
```bash
terraform destroy
```
Elimina la infraestructura (CUIDADO: no recuperable).

### Validar Sintaxis
```bash
terraform validate
terraform fmt
```
Verifica errores y formatea el código.

---

## 📝 ESTRUCTURA DE DIRECTORIOS

```
portcastello-ra6/
├── main.tf                    ← Archivo principal (lee primero)
├── variables.tf               ← Parámetros globales
├── terraform.tfvars           ← Valores concretos (edita aquí)
├── outputs.tf                 ← Información de salida
├── backend.tf                 ← Dónde se guarda el estado
│
├── modules/
│   ├── network/               ← VPC, subredes, gateways
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── compute/               ← EC2, Security Groups
│       ├── main.tf
│       ├── security.tf        ← Firewalls
│       ├── variables.tf
│       └── outputs.tf
│
└── scripts/                   ← Automatización
    ├── init_windows_dc.ps1    ← DC en Windows
    ├── init_server_dc.sh      ← DC en Ubuntu (Samba)
    ├── init_win_cli.ps1       ← Cliente Windows
    ├── init_linux_cli.sh      ← Cliente Linux
    └── init_linux_server.sh   ← Servidor Linux
```

---

## 🔐 VARIABLES CLAVE (terraform.tfvars)

```hcl
project_name     = "portcastello"          # Prefijo para recurso
aws_region        = "us-east-1"            # Región AWS
vpc_cidr          = "10.0.0.0/16"          # Rango IP principal
tipo_servidor_ad  = "ubuntu"               # "ubuntu" o "windows"
key_name          = "vockey"               # Key Pair en AWS
```

**Edita terraform.tfvars para personalizar.**

---

## 🛡️ SECURITY GROUPS (Firewall)

### DC (Dominio)
```
ENTRADA (desde VPC):
  - SSH 22
  - DNS 53 (TCP/UDP)
  - Kerberos 88
  - LDAP 389
  - SMB 445
  - RDP 3389
  - Otros puertos AD
```

### Cliente Windows (Público)
```
ENTRADA (desde internet):
  - RDP 3389 (0.0.0.0/0)
ENTRADA (desde VPC):
  - Todos los puertos
```

### Cliente Linux (Público)
```
ENTRADA (desde internet):
  - SSH 22 (0.0.0.0/0)
ENTRADA (desde VPC):
  - Todos los puertos
```

---

## 📊 INFORMACIÓN DE SALIDA POST-APPLY

Después de `terraform apply`, verás:

```
Outputs:

ip_dc_privada = "10.0.101.10"
ip_publica_win_cli = "54.123.45.67"
ip_publica_linux_cli = "54.123.45.68"
comando_rdp = "mstsc /v:54.123.45.67"
comando_ssh = "ssh -i labsuser.pem ubuntu@54.123.45.68"
```

---

## 🔄 FLUJO DE EJECUCIÓN

```
1. terraform init
   ↓ Descarga providers
   
2. terraform plan
   ↓ Calcula qué crear
   
3. terraform apply
   ↓ Crea recursos (5-10 min)
   
4. terraform output
   ↓ Muestra IPs
   
5. Conecta a WinCLI (RDP) o LinCLI (SSH)
   ↓ Máquinas se configuran via user data
   
6. Clientes se unen automáticamente al dominio
   ↓ Éxito: tienes lab con AD/Samba funcionando

7. Cuando terminates: terraform destroy
   ↓ Destruye TODO (evita costos)
```

---

## ⚡ TIPS PRÁCTICOS

### Cambiar SO del DC (sin destruir todo)
```bash
# En terraform.tfvars, cambiar:
tipo_servidor_ad = "windows"    # Era "ubuntu"

# Aplicar:
terraform apply

# Terraform solo recreará el DC
```

### Ver qué va a cambiar
```bash
terraform plan -out=tfplan
# Revisa tfplan
terraform apply tfplan
```

### Debug: Ver información de un recurso
```bash
terraform state show aws_instance.dc
terraform state list
```

### Salvar plan para después
```bash
terraform plan -out=mi_plan.plan
# Hacer commit de mi_plan.plan
terraform apply mi_plan.plan
```

---

## ❌ ERRORES COMUNES

| Error | Causa | Solución |
|-------|-------|----------|
| `Invalid region` | Región no existe | Usa us-east-1, us-west-2, etc. |
| `Error creating VPC` | Credenciales AWS inválidas | Configura `aws configure` |
| `Error: Missing required variable` | Falta variable | Revisa terraform.tfvars |
| `Security Group not found` | Módulo network no ejecutó | Verifica dependencias |
| `Instance type not available` | Tipo no en esa región | Cambia región o tipo |
| `Timeout waiting for...` | Recurso tarda mucho | Aumenta timeout (5-10 min) |

---

## 📚 DOCUMENTACIÓN RECOMENDADA

**Qué leer primero:**
1. README.md (5 min) - visión general
2. ARCHITECTURE.md (10 min) - cómo funciona
3. VARIABLES_GUIDE.md (5 min) - qué cambiar

**Si necesitas profundizar:**
4. MODULES_REFERENCE.md (15 min) - cada módulo
5. ANALISIS_DETALLADO.md (30 min) - todo archivo

**Antes de entregar:**
6. RUBRICA_EVALUACION.md - asegúrate de cumplir

---

## 🎯 CHECKLIST DE IMPLEMENTACIÓN

- [ ] Leer ENUNCIADO_TAREA.md completamente
- [ ] Inicializar git: `git init`
- [ ] Crear estructura de directorios
- [ ] Implementar modules/network/main.tf
- [ ] Implementar modules/network/variables.tf y outputs.tf
- [ ] Implementar modules/compute/main.tf
- [ ] Implementar modules/compute/security.tf
- [ ] Implementar modules/compute/variables.tf y outputs.tf
- [ ] Crear main.tf raíz
- [ ] Crear variables.tf raíz
- [ ] Crear terraform.tfvars
- [ ] Crear outputs.tf raíz
- [ ] Crear backend.tf
- [ ] `terraform init`
- [ ] `terraform plan` (sin errores)
- [ ] `terraform apply` (crear infraestructura)
- [ ] Verificar que todos los 5 servidores crearon
- [ ] Verificar outputs (IPs)
- [ ] Escribir README.md
- [ ] Escribir ARCHITECTURE.md
- [ ] Escribir VARIABLES_GUIDE.md
- [ ] Escribir MODULES_REFERENCE.md
- [ ] Escribir COSTS.md
- [ ] Comentar código
- [ ] `terraform destroy` (limpiar)
- [ ] Verificar con RUBRICA_EVALUACION.md
- [ ] Hacer commit final en git
- [ ] Entregar

---

## 🆘 COMO PEDIR AYUDA

Si te atascas:

1. **Lee el error completo** - casi siempre dice qué está mal
2. **Busca en ANALISIS_DETALLADO.md** - sección correspondiente
3. **Valida sintaxis:** `terraform validate`
4. **Revisa archivos source:** `terraform show`
5. **Lee Terraform docs:** https://www.terraform.io/docs
6. **Pregunta al instructor** con detalles del error

---

## ✅ CRITERIOS IMPORTANTES

Para pasar (70% mínimo):

```
✅ Código compila sin errores
✅ Todos los 5 servidores se crean
✅ Security Groups están configurados
✅ Cliente Windows es accesible por RDP
✅ Cliente Linux es accesible por SSH
✅ Servidor privado puede acceder a internet (NAT)
✅ README.md existe y explica cómo usar
✅ ARCHITECTURE.md existe con diagrama
```

Para sobresaliente (90%+):

```
✅ Código está bien documentado y limpio
✅ User Data scripts funcionan perfectamente
✅ Clientes se unen automáticamente al dominio
✅ IPs privadas fijas están correctamente configuradas
✅ Documentación completa y clara
✅ Ejemplos personalizados de uso
✅ Tips de troubleshooting incluidos
✅ Estimación de costos correcta
```

---

## 📞 REFERENCIA RÁPIDA

**Documentos:**
- ENUNCIADO_TAREA.md - QUÉ HACER
- ANALISIS_DETALLADO.md - CÓMO FUNCIONA
- RUBRICA_EVALUACION.md - CÓMO SE EVALÚA
- Este archivo - QUICK REFERENCE

**Comandos:**
```bash
terraform init     # Una vez
terraform plan     # Ver antes de crear
terraform apply    # Crear infraestructura
terraform output   # Ver IPs
terraform destroy  # Eliminar todo
```

**Archivos Key:**
- `terraform.tfvars` - Cambia aquí los valores
- `main.tf` - Archivo principal
- `modules/network/main.tf` - VPC y red
- `modules/compute/main.tf` - Servidores

---

**¡Buena suerte! 🚀**

