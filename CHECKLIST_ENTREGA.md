# CHECKLIST DE ENTREGA - PORTCASTELLO RA6

**Estudiante:** ____________________  
**Fecha de Entrega:** ____________________  
**Evaluador:** ____________________  

---

## ✅ ANTES DE ENTREGAR

Usa este checklist para verificar que TODO está completo antes de entregar.

---

## 📋 SECCIÓN 1: ARCHIVOS TERRAFORM (Core)

### Archivos Raíz
- [ ] `main.tf` - Orquestación principal con módulos
- [ ] `variables.tf` - Variables globales con descripciones
- [ ] `terraform.tfvars` - Valores personalizados (mínimo project_name)
- [ ] `outputs.tf` - Outputs con IPs y comandos
- [ ] `backend.tf` - Backend S3 configurado
- [ ] `.terraform.lock.hcl` - Lockfile de versiones

**Verificación:**
- [ ] `terraform validate` pasa sin errores
- [ ] `terraform fmt` formatea correctamente
- [ ] No hay secrets en los archivos

---

### Módulo Network
- [ ] `modules/network/main.tf`:
  - [ ] VPC con CIDR 10.0.0.0/16
  - [ ] 2 subredes públicas
  - [ ] 2 subredes privadas
  - [ ] Internet Gateway
  - [ ] NAT Gateway con Elastic IP
  - [ ] Tablas de rutas configuradas
  
- [ ] `modules/network/variables.tf` - Variables bien documentadas
- [ ] `modules/network/outputs.tf` - Exporta vpc_id, subnet_ids, etc.

**Verificación:**
- [ ] El módulo compila sin errores
- [ ] Outputs son referenciados correctamente en compute

---

### Módulo Compute
- [ ] `modules/compute/main.tf`:
  - [ ] AMI data sources para Ubuntu y Windows (dinámico)
  - [ ] Locals para lógica condicional (tipo_servidor_ad)
  - [ ] Instancia DC con IP fija .10
  - [ ] Instancia Linux Server con IP fija .20
  - [ ] Instancia Cliente Windows en pública + EIP
  - [ ] Instancia Cliente Linux en pública + EIP
  
- [ ] `modules/compute/security.tf`:
  - [ ] SG DC con puertos AD
  - [ ] SG Servidor Linux con SSH, SMB, NFS
  - [ ] SG Cliente Windows con RDP público
  - [ ] SG Cliente Linux con SSH público
  - [ ] Restricciones CIDR correctas
  
- [ ] `modules/compute/variables.tf` - Variables bien documentadas
- [ ] `modules/compute/outputs.tf` - Exporta IPs privadas/públicas

**Verificación:**
- [ ] El módulo compila sin errores
- [ ] IPs privadas son fijas (cidrhost correctamente usado)

---

## 📱 SECCIÓN 2: SCRIPTS DE AUTOMATIZACIÓN

- [ ] `scripts/init_windows_dc.ps1`
  - [ ] Instala AD / Configura DC
  - [ ] Sin errores de sintaxis PowerShell
  
- [ ] `scripts/init_server_dc.sh`
  - [ ] Instala Samba / Configura DC
  - [ ] Sin errores de sintaxis Bash
  
- [ ] `scripts/init_win_cli.ps1`
  - [ ] Configura cliente Windows
  - [ ] Intenta unirse al dominio
  
- [ ] `scripts/init_linux_cli.sh`
  - [ ] Configura cliente Linux
  - [ ] Intenta unirse al dominio
  
- [ ] `scripts/init_linux_server.sh`
  - [ ] Configura servidor Linux
  - [ ] Configura Samba como miembro

**Verificación:**
- [ ] Todos los scripts tienen formato correcto (Unix/Windows)
- [ ] No hay caracteres especiales que causen errores

---

## 📚 SECCIÓN 3: DOCUMENTACIÓN REQUERIDA

### 3.1 README.md
- [ ] Existe en la raíz
- [ ] Contiene:
  - [ ] Descripción general (3-5 líneas)
  - [ ] Diagrama ASCII de la arquitectura
  - [ ] Tabla con los 5 servidores (SO, IP, Rol)
  - [ ] Requisitos previos (AWS, Terraform, CLI)
  - [ ] Pasos para desplegar (init, plan, apply)
  - [ ] Pasos para destruir
  - [ ] Ejemplo de output
  - [ ] Troubleshooting (3-5 problemas)

**Verificación:**
- [ ] Markdown está bien formateado
- [ ] Todos los comandos están correctos

---

### 3.2 ARCHITECTURE.md
- [ ] Existe
- [ ] Contiene:
  - [ ] Diagrama detallado (ASCII o descripción)
  - [ ] Explicación de cada componente
  - [ ] Flujo de red (entrada/salida)
  - [ ] Justificación de decisiones
  - [ ] Patrones de seguridad explicados
  - [ ] Tabla resumen de componentes

**Verificación:**
- [ ] Diagrama es claro y comprensible
- [ ] Explicaciones son técnicamente correctas

---

### 3.3 VARIABLES_GUIDE.md
- [ ] Existe
- [ ] Contiene para cada variable:
  - [ ] Nombre y tipo
  - [ ] Default value
  - [ ] Descripción clara
  - [ ] Rango de valores permitidos
  - [ ] Ejemplo de uso
- [ ] Incluye ejemplos de terraform.tfvars personalizados

**Verificación:**
- [ ] Todas las variables están documentadas
- [ ] Ejemplos son realistas

---

### 3.4 MODULES_REFERENCE.md
- [ ] Existe
- [ ] Para cada módulo (network, compute):
  - [ ] Descripción del propósito
  - [ ] Lista de variables (inputs)
  - [ ] Lista de outputs
  - [ ] Recursos creados (lista)
  - [ ] Dependencias
  - [ ] Ejemplo de uso

**Verificación:**
- [ ] Referencias son precisas
- [ ] Correspond con el código actual

---

### 3.5 COSTS.md
- [ ] Existe
- [ ] Contiene:
  - [ ] Estimación de costo mensual
  - [ ] Desglose por tipo de recurso
  - [ ] Asunciones (región, sizing)
  - [ ] Tips para reducir costos
  - [ ] Nota sobre AWS Academy (si aplica)
  - [ ] Comparativa (mensual vs anual)

**Verificación:**
- [ ] Cálculos son aproximadamente correctos
- [ ] Incluye todos los recursos

---

### 3.6 Documentación en Código
- [ ] Comentarios en secciones complejas
- [ ] Descripciones en todas las variables
- [ ] Descripciones en todos los outputs
- [ ] Bloques delimitados con separadores
- [ ] Sin código muerto o comentado

**Verificación:**
- [ ] El código es fácil de leer
- [ ] Un tercero puede entender sin ayuda

---

## 🔍 SECCIÓN 4: VERIFICACIÓN TÉCNICA

### Funcionamiento Básico
- [ ] `terraform init` sin errores
- [ ] `terraform validate` sin errores
- [ ] `terraform plan` sin errores (lee qué crear)
- [ ] `terraform apply` completa sin errores
- [ ] Todos los 5 servidores se crean
- [ ] `terraform output` muestra IPs correctas
- [ ] `terraform destroy` limpia sin errores

**Verificación:**
- [ ] Infraestructura completamente funcional
- [ ] No hay recursos huérfanos

---

### Arquitectura de Red
- [ ] VPC existe con CIDR correcto
- [ ] 4 subredes creadas en 2 AZ
- [ ] Subredes tienen CIDR correcto
- [ ] IGW está adjunto a VPC
- [ ] NAT GW existe en subred pública
- [ ] Tablas de rutas están configuradas
- [ ] Rutas apuntan a los gateways correctos

**Verificación:**
- [ ] Abre AWS Console y verifica estructura
- [ ] El networking es correcto

---

### Instancias EC2
- [ ] DC está en subred privada (IP 10.0.101.10)
- [ ] Linux Server está en subred privada (IP 10.0.101.20)
- [ ] Win CLI está en subred pública + EIP
- [ ] Linux CLI está en subred pública + EIP
- [ ] Tipos de instancia correctos (t3.small/medium)
- [ ] Almacenamiento correcto (20-50 GB)
- [ ] Key Pair está configurado
- [ ] User Data scripts se ejecutan

**Verificación:**
- [ ] Abre AWS Console y verifica cada instancia
- [ ] IPs son las esperadas
- [ ] Instancias están "running"

---

### Security Groups
- [ ] DC SG permite puertos requeridos
- [ ] Servidor Linux SG permite SSH, SMB, NFS
- [ ] Cliente Windows SG permite RDP desde 0.0.0.0/0
- [ ] Cliente Linux SG permite SSH desde 0.0.0.0/0
- [ ] Todos permiten tráfico interno VPC
- [ ] Todos permiten egress sin restricción
- [ ] Sin sobreprivilegio (no abierto al mundo sin necesidad)

**Verificación:**
- [ ] Abre AWS Console y revisa cada SG
- [ ] Puertos permitidos son correctos

---

### Automatización
- [ ] User Data scripts están en instancias
- [ ] Scripts ejecutan sin errores (verificar logs)
- [ ] Clientes se unen al dominio (verificar si LDAP responde)
- [ ] DNS resuelve correctamente (probar dig/nslookup)
- [ ] Compartición SMB es accesible

**Verificación (opcional, depende de scripts):**
- [ ] Conecta a un cliente y verifica status de dominio
- [ ] Prueba resolución DNS

---

## 📊 SECCIÓN 5: CALIDAD Y MEJORES PRÁCTICAS

### Código Terraform
- [ ] Nombres siguen convención (kebab-case para recursos, snake_case para variables)
- [ ] Variables están tipadas (string, list, number)
- [ ] Valores por defecto son sensatos
- [ ] Validaciones están presentes (ej: contains())
- [ ] No hay hardcoding de IDs (usa variables/locals)
- [ ] Locals se usan para lógica compleja
- [ ] Data sources son dinámicos (no AMI ID hardcodeado)
- [ ] Count loops son claros
- [ ] Depends_on está presente donde es necesario
- [ ] Tags son consistentes

**Verificación:**
- [ ] Revisa el código manualmente
- [ ] Pregúntate: "¿Otro programador lo entendería?"

---

### Modularización
- [ ] Network y compute están separados
- [ ] Cada módulo tiene su responsabilidad clara
- [ ] No hay dependencias cíclicas
- [ ] Outputs de un módulo alimentan inputs del otro
- [ ] main.tf es simple y legible

**Verificación:**
- [ ] main.tf no tiene más de 50 líneas
- [ ] Se podría reutilizar el módulo network en otro proyecto

---

### Documentación
- [ ] Todos los archivos .md están bien formateados
- [ ] No hay faltas de ortografía (revisa dos veces)
- [ ] Los ejemplos funcionan (probados)
- [ ] Las referencias son correctas (links/rutas)
- [ ] Tablas están alineadas
- [ ] Diagramas son claros

**Verificación:**
- [ ] Pasa control de ortografía
- [ ] Un tercero puede seguir las instrucciones

---

## 📋 SECCIÓN 6: ESTRUCTURA DE ENTREGA

Verifica que la estructura sea exactamente:

```
portcastello-ra6/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── backend.tf
├── .terraform.lock.hcl
├── tfplan (opcional)
├── README.md
├── ARCHITECTURE.md
├── VARIABLES_GUIDE.md
├── MODULES_REFERENCE.md
├── COSTS.md
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── main.tf
│       ├── security.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    ├── init_windows_dc.ps1
    ├── init_server_dc.sh
    ├── init_win_cli.ps1
    ├── init_linux_cli.sh
    └── init_linux_server.sh
```

- [ ] Todos los archivos están presentes
- [ ] No hay archivos extra innecesarios (.pem, tfstate, etc.)
- [ ] Estructura es exactamente como se especificó

---

## ⚠️ SECCIÓN 7: COSAS A EVITAR

- [ ] ❌ NO incluyas `terraform.tfstate` (estados binarios)
- [ ] ❌ NO incluyas `.terraform/` (carpeta de módulos)
- [ ] ❌ NO dejes variables hardcodeadas (usa terraform.tfvars)
- [ ] ❌ NO incluyas keys/secrets en el código
- [ ] ❌ NO dejes código comentado sin razón
- [ ] ❌ NO uses nombres confusos para recursos
- [ ] ❌ NO dejes TODO o FIXME sin resolver
- [ ] ❌ NO olvides documenta correctamente

**Verificación:**
- [ ] `git status` no muestra archivos no deseados
- [ ] No hay secretos en ningún archivo

---

## 🎯 SECCIÓN 8: AUTOEVALUACIÓN CON RÚBRICA

Usa RUBRICA_EVALUACION.md para autoevaluarse:

### Funcionalidad (0-40 puntos)
- [ ] Despliegue exitoso: ___/10
- [ ] Infraestructura de red: ___/8
- [ ] Instancias EC2: ___/10
- [ ] Security Groups: ___/12
- **Subtotal:** ___/40

### Código Terraform (0-30 puntos)
- [ ] Estructura y modularidad: ___/8
- [ ] Variables y outputs: ___/7
- [ ] Técnicas avanzadas: ___/8
- [ ] Documentación en código: ___/7
- **Subtotal:** ___/30

### Documentación (0-20 puntos)
- [ ] README.md: ___/5
- [ ] ARCHITECTURE.md: ___/5
- [ ] Guías especializadas: ___/5
- [ ] Calidad general: ___/5
- **Subtotal:** ___/20

### Automatización (0-10 puntos)
- [ ] User Data scripts: ___/10
- **Subtotal:** ___/10

### **TOTAL ESTIMADO:** ___/100

---

## 📤 SECCIÓN 9: PREPARACIÓN PARA ENTREGA

### Si es por Email:
- [ ] Comprimir carpeta: `portcastello-ra6.zip`
- [ ] Nombre: `APELLIDO_portcastello-ra6.zip`
- [ ] Asunto: `[RA6] Portcastello - APELLIDO`
- [ ] Verificar tamaño < 50 MB

### Si es por Git:
- [ ] Repositorio inicializado: `git init`
- [ ] .gitignore contiene `.terraform/`, `*.tfstate`, etc.
- [ ] Commits significativos (no todo en uno)
- [ ] README.md visible en raíz
- [ ] Push a rama `main` o especificada

### Si es en Plataforma:
- [ ] Subir archivo zip o carpeta completa
- [ ] Verificar que se subió correctamente
- [ ] Anotar fecha/hora de entrega

- [ ] Realizado el paso de entrega correspondiente

---

## ✅ CHECKLIST FINAL

Antes de hacer clic en "ENVIAR":

- [ ] He leído TODO este checklist
- [ ] He completado todas las secciones
- [ ] Todos los checkboxes de secciones 1-7 están marcados
- [ ] Mi autoevaluación de rúbrica es >= 70
- [ ] He probado terraform init/plan/apply/destroy
- [ ] He revisado la estructura de entrega
- [ ] He evitado todas las cosas de la sección 7
- [ ] Estoy listo para entregar

---

## 📝 NOTAS PERSONALES

Uso este espacio para notas:

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## ✋ FIRMA Y DECLARACIÓN

Declaro que:
- ✅ Este trabajo es completamente mío
- ✅ He seguido la rúbrica de evaluación
- ✅ Todo el código está funcional
- ✅ La documentación es completa y clara
- ✅ Estoy satisfecho con mi entrega

**Nombre:** ________________________

**Fecha:** ________________________

**Firma:** ________________________

---

**¡LISTO PARA ENVIAR! 🚀**

Una vez completado este checklist, tu tarea está lista para entrega.

