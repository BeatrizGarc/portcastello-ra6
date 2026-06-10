# LA CARPETA `.terraform/` - EXPLICACIÓN DETALLADA

## 🎯 Resumen Rápido

```
.terraform/
├── modules/          → Referencias a módulos locales
├── providers/        → Plugins de AWS descargados
└── terraform.tfstate → Estado del despliegue
```

**¿Qué es?** Una carpeta que Terraform crea automáticamente.  
**¿Cuándo se crea?** Al ejecutar `terraform init`.  
**¿Debo hacerle commit?** NO - Debe estar en `.gitignore`.  
**¿Se regenera?** Sí, automáticamente con `terraform init`.  
**¿Cuánto pesa?** ~300-500 MB (los providers son grandes).  

---

## 📂 ESTRUCTURA COMPLETA

```
.terraform/
│
├── modules/
│   └── modules.json
│       ├── path: ./modules/network
│       ├── path: ./modules/compute
│       └── (referencias a módulos locales)
│
├── providers/
│   └── registry.terraform.io/
│       └── hashicorp/
│           └── aws/
│               └── 6.47.0/                    ← Versión exacta
│                   └── linux_amd64/           ← Sistema operativo
│                       ├── terraform-provider-aws_v6.47.0_x5  ← Plugin ejecutable
│                       └── LICENSE.txt
│
└── terraform.tfstate    ← Archivo que guarda estado (NO es el state en S3)
```

---

## 1️⃣ CARPETA `modules/` - Referencias a Módulos

### ¿Qué contiene?

Un único archivo: `modules.json`

### ¿Qué es `modules.json`?

Archivo de metadatos que lista los módulos locales del proyecto.

### Ejemplo de contenido:

```json
{
  "Modules": [
    {
      "Key": "network",
      "Source": "./modules/network",
      "Dir": ".terraform/modules/network"
    },
    {
      "Key": "compute",
      "Source": "./modules/compute",
      "Dir": ".terraform/modules/compute"
    }
  ]
}
```

### ¿Para qué sirve?

- ✓ Terraform sabe dónde están los módulos
- ✓ Evita tener que buscar módulos
- ✓ Acelera ejecución (no rescrea referencias)
- ✓ Permite modo offline (módulos ya descargados)

### ¿Cómo se genera?

Automáticamente cuando haces:
```bash
terraform init
```

Terraform lee `main.tf`, ve:
```hcl
module "network" {
  source = "./modules/network"
}
```

Y crea la referencia en `modules.json`.

### ¿Puedo editarlo?

❌ NO. Es generado automáticamente.

---

## 2️⃣ CARPETA `providers/` - Plugins de AWS

### ¿Qué contiene?

Los plugins (programas ejecutables) de los providers que necesitas.

### Ruta completa:

```
.terraform/providers/
└── registry.terraform.io/
    └── hashicorp/
        └── aws/
            └── 6.47.0/                    ← VERSIÓN
                └── linux_amd64/
                    ├── terraform-provider-aws_v6.47.0_x5
                    └── LICENSE.txt
```

### ¿Qué es `terraform-provider-aws_v6.47.0_x5`?

Un programa ejecutable (binary) que actúa como plugin.

**¿Qué hace?**
- Lee tus archivos `.tf` (main.tf, variables.tf, etc.)
- Traduce Terraform a llamadas AWS API
- Comunica con AWS (crear, actualizar, eliminar recursos)

**¿Es código?**
- Sí, es compilado (binario, no texto)
- Es el verdadero "intérprete" de Terraform

### ¿Cómo se descarga?

Cuando haces `terraform init`:
```
terraform init
  ↓
Lee main.tf
  ↓
Identifica: required_providers { aws >= 4.44.0 }
  ↓
Descarga provider AWS versión 6.47.0
  ↓
Lo coloca en .terraform/providers/
```

### ¿Por qué `6.47.0`?

Porque el archivo `terraform.lock.hcl` especifica esa versión exacta.

**Sin el lockfile, podrías tener:**
```
Primera vez: descarga 6.47.0
Segunda vez: descarga 6.48.0 (versión más nueva)
Resultado: ¡Código se comporta diferente! ❌
```

**Con el lockfile:**
```
Primera vez: descarga 6.47.0 (guardado en lock)
Segunda vez: descarga 6.47.0 (forzado por lock)
Resultado: ¡Mismo comportamiento! ✅
```

### ¿Por qué `linux_amd64`?

El plugin es **específico del sistema operativo**.

- `linux_amd64` → Para Linux de 64 bits
- `darwin_arm64` → Para Mac M1/M2
- `windows_amd64` → Para Windows de 64 bits

Terraform automáticamente descarga la versión correcta para tu SO.

### ¿Cuánto pesa?

```
terraform-provider-aws_v6.47.0_x5 → ~150-200 MB
LICENSE.txt → ~1 KB
```

**Nota:** AWS provider es el más pesado. Otros providers son más ligeros.

### ¿Puedo editarlo?

❌ NO. Es un binario compilado.

### ¿Puedo borrarlo?

⚠️ Sí, pero Terraform lo descargará de nuevo con `terraform init`.

```bash
rm -r .terraform/providers/
terraform init   # Descarga nuevamente
```

---

## 3️⃣ ARCHIVO `.terraform/terraform.tfstate`

### ⚠️ IMPORTANTE - LEE ESTO

**Este archivo NO es el state principal.**

**Estado Principal está en:**
```
S3 bucket: portcastello-tfstate-202605
Key: ra6/portcastello.tfstate
```

**Entonces, ¿qué es `.terraform/terraform.tfstate`?**

Es un **cache local temporal** que Terraform crea.

### ¿Por qué existe?

Terraform necesita un estado local para funcionar en modo offline.

**Sin cache local:**
```
terraform plan
  ↓
Conecta a S3 cada vez ❌ Lento
  ↓
Descargar estado de S3
  ↓
Procesa plan
```

**Con cache local:**
```
terraform plan
  ↓
Lee cache local (.terraform/terraform.tfstate) ✅ Rápido
  ↓
Procesa plan
  ↓
Al final, sincroniza con S3
```

### ¿Qué contiene?

Información sobre los recursos que Terraform ha creado:

```json
{
  "version": 4,
  "terraform_version": "1.3.0",
  "serial": 25,
  "lineage": "abc123...",
  "outputs": {
    "ip_dc_privada": {
      "value": "10.0.101.10"
    }
  },
  "resources": [
    {
      "type": "aws_vpc",
      "name": "main",
      "instances": [
        {
          "attributes": {
            "id": "vpc-123456",
            "cidr_block": "10.0.0.0/16"
          }
        }
      ]
    }
    // ... más recursos ...
  ]
}
```

### ¿Puedo editarlo?

❌ NO. Nunca edites esto a mano.

### ¿Puedo borrarlo?

⚠️ Técnicamente sí, pero:
- Terraform pensará que no hay recursos
- Si haces `terraform apply`, creará duplicados
- Usa solo si entiendes las consecuencias

**Opción segura:**
```bash
terraform refresh   # Sincroniza con AWS
```

### ¿Se sube a Git?

❌ NO - Debe estar en `.gitignore`

```
.gitignore
├── .terraform/
├── *.tfstate
├── *.tfstate.*
└── terraform.lock.hcl  ← Este SÍ va a Git
```

---

## 📋 FLUJO COMPLETO: Qué Sucede en `.terraform/`

### Paso 1: terraform init

```
Comandos:
$ terraform init

Proceso:
├─ 1. Lee main.tf
│  └─ Identifica: module "network" y module "compute"
│
├─ 2. Crea: .terraform/modules/modules.json
│  └─ Registra referencias a módulos locales
│
├─ 3. Lee: required_providers { aws >= 4.44.0 }
│
├─ 4. Descarga provider AWS versión 6.47.0
│  └─ Coloca en: .terraform/providers/registry.terraform.io/hashicorp/aws/6.47.0/linux_amd64/
│
├─ 5. Crea cache: .terraform/terraform.tfstate
│  └─ Estado vacío (aún no hemos creado recursos)
│
└─ 6. Genera: .terraform.lock.hcl
   └─ Bloquea versión de provider (6.47.0)

Resultado:
✅ .terraform/ carpeta lista
✅ Plugins descargados
✅ Módulos referenciados
✅ Cache de estado creado
```

### Paso 2: terraform plan

```
Comandos:
$ terraform plan

Proceso:
├─ 1. Lee: main.tf, variables.tf, terraform.tfvars
│
├─ 2. Carga referencia de módulos desde: .terraform/modules/modules.json
│  ├─ Lee: modules/network/main.tf
│  └─ Lee: modules/compute/main.tf
│
├─ 3. Usa plugin AWS desde: .terraform/providers/.../terraform-provider-aws_v6.47.0_x5
│
├─ 4. Lee cache de estado: .terraform/terraform.tfstate
│  └─ (Está vacío, aún no hay recursos)
│
├─ 5. Conecta a AWS API
│  └─ "¿Existen estos recursos en AWS?"
│
├─ 6. Compara:
│  ├─ Lo que Terraform quiere crear (del plan)
│  └─ Lo que existe en AWS (ninguno, es primera vez)
│
└─ 7. Genera plan (tfplan)
   └─ "Crear 30 recursos"

Resultado:
✅ Plan generado
✅ Plugin AWS usado correctamente
✅ Cache de estado consultado
```

### Paso 3: terraform apply

```
Comandos:
$ terraform apply

Proceso:
├─ 1. Lee plugin AWS desde: .terraform/providers/.../terraform-provider-aws_v6.47.0_x5
│
├─ 2. Ejecuta el plan
│  └─ Crea todos los recursos en AWS
│
├─ 3. Actualiza cache: .terraform/terraform.tfstate
│  └─ Guarda IDs de recursos creados
│
├─ 4. Conecta a backend S3
│  ├─ Carga state desde: s3://portcastello-tfstate-202605/ra6/portcastello.tfstate
│  ├─ Compara con cache local
│  └─ Sincroniza (iguala ambos)
│
└─ 5. Activa DynamoDB lock
   └─ Libera bloqueo

Resultado:
✅ Recursos creados en AWS
✅ Cache local actualizado
✅ State en S3 sincronizado
✅ Infrastructure completamente operativa
```

---

## 🔄 Relación Entre Archivos de Estado

```
┌─────────────────────────────────────────────────────┐
│ LOCAL (en tu computadora)                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│ .terraform/terraform.tfstate (CACHE)                │
│ └─ Copia local de state                            │
│ └─ Usado para operaciones offline                  │
│ └─ Sincroniza con S3 periódicamente                │
│                                                     │
└─────────────────────────────────────────────────────┘
                         ↕️ (sincroniza)
┌─────────────────────────────────────────────────────┐
│ AWS S3 (en la nube)                                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│ s3://portcastello-tfstate-202605/                  │
│ └─ ra6/portcastello.tfstate (STATE PRINCIPAL)      │
│ └─ Guardado en S3 (compartido entre usuarios)      │
│ └─ Encriptado                                      │
│ └─ Con bloqueo en DynamoDB                         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Analogía:**
- `.terraform/terraform.tfstate` = Tu copia local del documento
- `s3://portcastello-tfstate-202605/.../tfstate` = Documento original en la nube
- Al colaborar, ambos se sincronizan

---

## ⚙️ OPERACIONES COMUNES

### ¿Qué pasa si elimino `.terraform/`?

```bash
rm -r .terraform/
```

**Resultado:**
```
✅ Terraform seguirá funcionando
✅ terraform plan/apply descargarán todo nuevamente
✅ Los recursos en AWS no se verán afectados
⏱️ Tardará 2-3 minutos en descargar providers
```

**Caso de uso:** Si la carpeta está corrupta o necesitas liberar espacio.

### ¿Qué pasa si elimino `.terraform/terraform.tfstate`?

```bash
rm .terraform/terraform.tfstate
```

**⚠️ Resultado - CUIDADO:**
```
❌ Terraform pensará que no hay recursos locales
❌ Si haces terraform apply, intentará crear duplicados
❌ Los recursos en AWS se duplicarán
✅ Solución: terraform refresh (re-sincroniza)
```

**NO lo hagas a menos que sepas lo que haces.**

### ¿Cómo sincronizo manualmente?

```bash
terraform refresh
```

**Qué hace:**
- Lee estado actual en AWS
- Actualiza cache local `.terraform/terraform.tfstate`
- Sincroniza todo

### ¿Cómo veo qué hay en el state?

```bash
terraform state list
# Muestra todos los recursos

terraform state show aws_instance.dc
# Muestra detalles de un recurso específico

terraform state pull
# Descarga el state completo (JSON)
```

---

## 🛡️ SEGURIDAD - IMPORTANTE

### ❌ NUNCA:
- ❌ Hagas commit de `.terraform/` en Git
- ❌ Edites `.terraform/terraform.tfstate` a mano
- ❌ Compartas `.terraform/` entre usuarios
- ❌ Copies `.terraform/` de otra máquina

### ✅ SIEMPRE:
- ✅ Añade `.terraform/` a `.gitignore`
- ✅ Haz commit de `.terraform.lock.hcl`
- ✅ Usa `terraform init` en cada máquina
- ✅ Déjale a Terraform que gestione `.terraform/`

### .gitignore Correcto:

```
.gitignore
├── .terraform/          ← Carpeta completa
├── *.tfstate           ← Archivos de estado
├── *.tfstate.*         ← Backups de estado
├── .terraform.tfstate  ← Cache de estado
└── crash.log           ← Logs de error
```

---

## 📊 RESUMEN VISUAL

```
┌─────────────────────────────────────────┐
│  TU COMPUTADORA                         │
├─────────────────────────────────────────┤
│                                         │
│  main.tf ┐                              │
│  vars.tf ├─→ terraform init             │
│  etc.    ┘    ↓                          │
│               Crea .terraform/          │
│               ├─ modules/               │
│               ├─ providers/ (AWS)       │
│               └─ tfstate (cache)        │
│                                         │
│  ↓ terraform plan                       │
│  Consulta .terraform/tfstate (cache)   │
│  ↓                                      │
│  Plan generado                          │
│                                         │
│  ↓ terraform apply                      │
│  Usa plugin AWS                         │
│  Crea recursos en AWS ➜               │
│                                         │
└────────────────────────────┬────────────┘
                             │
                    API AWS  │
                             │
          ┌──────────────────┴──────────────┐
          │                                 │
   ┌──────────────────┐          ┌─────────────────┐
   │ AWS Resources    │          │ S3 Backend      │
   ├──────────────────┤          ├─────────────────┤
   │ • VPC            │          │ portcastello-   │
   │ • Subnets        │          │ tfstate-202605  │
   │ • EC2 instances  │          │ └─ tfstate      │
   │ • Security Groups│          │    (principal)  │
   │ • EIPs           │          │                 │
   └──────────────────┘          └─────────────────┘
```

---

## 🎯 CONCLUSIÓN

| Aspecto | Explicación |
|---------|-------------|
| **¿Qué es?** | Carpeta que Terraform genera automáticamente |
| **¿Cuándo se crea?** | `terraform init` |
| **¿Qué contiene?** | Módulos, providers, cache de estado |
| **¿Debo hacer commit?** | NO - Va en `.gitignore` |
| **¿Se regenera?** | Sí - Con `terraform init` |
| **¿Puedo editarlo?** | NO - Déjale a Terraform |
| **¿Ocupa espacio?** | Sí - ~300-500 MB (providers pesados) |
| **¿Es importante?** | Sí - Necesario para que Terraform funcione |

**TL;DR:** `.terraform/` es la "caja de herramientas" de Terraform. No la toques, Terraform la gestiona automáticamente.

