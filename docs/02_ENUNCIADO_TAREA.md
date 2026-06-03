# ENUNCIADO DE TAREA: PORTCASTELLO RA6
## Infraestructura de Laboratorio de Active Directory en AWS con Terraform

---

## 📋 INFORMACIÓN GENERAL

**Asignatura:** IaaC en el Núvol: Terraform i AWS CloudFormation  
**Módulo:** SOR (Sistema Operativo en Red) - RA6  
**Nivel:** Avanzado  
**Horas Estimadas:** 20-30 horas  
**Formato:** Entrega de Código (Terraform) + Documentación

---

## 🎯 OBJETIVO GENERAL

Diseñar e implementar una **infraestructura completa de laboratorio educativo en AWS** utilizando **Terraform** (Infrastructure as Code) que permita a estudiantes practicar **administración de Active Directory, gestión de dominios y conceptos de networking en la nube**.

La solución debe ser:
- ✅ **Automatizada:** Desplegable con un solo comando (`terraform apply`)
- ✅ **Modular:** Separada en componentes reutilizables (red, cómputo)
- ✅ **Escalable:** Fácil de modificar y adaptar
- ✅ **Educativa:** Incluir documentación clara del código
- ✅ **Segura:** Aplicar principios de seguridad en la nube (VPC, SG, IP privadas)

---

## 📐 REQUISITOS ARQUITECTÓNICOS

### 1. Red (VPC)
- [ ] Crear una VPC con CIDR 10.0.0.0/16
- [ ] Implementar 4 subredes en 2 zonas de disponibilidad (HA):
  - 2 subredes públicas (10.0.1.0/24, 10.0.2.0/24)
  - 2 subredes privadas (10.0.101.0/24, 10.0.102.0/24)
- [ ] Configurar Internet Gateway (IGW) para acceso a internet
- [ ] Crear NAT Gateway para que servidores privados accedan a internet sin exponerse
- [ ] Configurar tablas de rutas con rutas adecuadas

### 2. Cómputo (EC2 Instances)
Desplegar 5 instancias en las siguientes configuraciones:

#### 2.1 Controlador de Dominio (DC)
- [ ] SO configurable: Ubuntu 22.04 (Samba) o Windows Server 2019 (AD)
- [ ] Ubicación: Subred privada
- [ ] Instance Type: t3.medium (Windows) o t3.small (Ubuntu)
- [ ] IP Privada Fija: 10.0.101.10
- [ ] Almacenamiento: 50 GB (Windows) o 20 GB (Ubuntu)
- [ ] User Data: Script de inicialización automática
- [ ] Security Group: Restringido a tráfico interno VPC

#### 2.2 Servidor Linux Miembro
- [ ] SO: Ubuntu 22.04
- [ ] Ubicación: Subred privada
- [ ] Instance Type: t3.small
- [ ] IP Privada Fija: 10.0.101.20
- [ ] Almacenamiento: 20 GB
- [ ] Rol: Cliente del dominio, servidor de archivos (Samba)
- [ ] User Data: Script para unirse al dominio
- [ ] Security Group: Puertos SSH, SMB, NFS desde VPC

#### 2.3 Cliente Windows
- [ ] SO: Windows Server 2019
- [ ] Ubicación: Subred pública
- [ ] Instance Type: t3.medium
- [ ] IP Pública: Elastic IP (fija)
- [ ] Almacenamiento: 30 GB
- [ ] Acceso: RDP público (puerto 3389)
- [ ] Rol: Cliente unido al dominio
- [ ] User Data: Script para unirse al dominio
- [ ] Security Group: RDP abierto a internet, interno para VPC

#### 2.4 Cliente Linux
- [ ] SO: Ubuntu 22.04
- [ ] Ubicación: Subred pública
- [ ] Instance Type: t3.small
- [ ] IP Pública: Elastic IP (fija)
- [ ] Almacenamiento: 15 GB
- [ ] Acceso: SSH público (puerto 22)
- [ ] Rol: Cliente unido al dominio
- [ ] User Data: Script para unirse al dominio
- [ ] Security Group: SSH abierto a internet, interno para VPC

### 3. Seguridad (Security Groups)
- [ ] SG para DC: Puertos AD/Samba (DNS, Kerberos, LDAP, SMB, RDP)
- [ ] SG para Servidor Linux: Puertos Samba (SSH, SMB, NFS)
- [ ] SG para Cliente Windows: RDP público + interno VPC
- [ ] SG para Cliente Linux: SSH público + interno VPC
- [ ] Todos los SGs deben permitir salida sin restricciones

---

## 💻 REQUISITOS DE CÓDIGO TERRAFORM

### Estructura de Directorios
```
portcastello-ra6/
├── main.tf                    # Archivo principal (orquestación)
├── variables.tf               # Variables globales
├── terraform.tfvars           # Valores de variables
├── outputs.tf                 # Outputs con IPs y comandos
├── backend.tf                 # Configuración de estado S3
├── .terraform.lock.hcl        # Lockfile de versiones
├── modules/
│   ├── network/
│   │   ├── main.tf            # Recursos de VPC
│   │   ├── variables.tf       # Variables del módulo
│   │   └── outputs.tf         # Outputs del módulo
│   └── compute/
│       ├── main.tf            # Recursos EC2
│       ├── security.tf        # Security Groups
│       ├── variables.tf       # Variables del módulo
│       └── outputs.tf         # Outputs del módulo
└── scripts/
    ├── init_windows_dc.ps1    # PowerShell: Setup DC Windows
    ├── init_server_dc.sh      # Bash: Setup DC Samba
    ├── init_win_cli.ps1       # PowerShell: Setup cliente Windows
    ├── init_linux_cli.sh      # Bash: Setup cliente Linux
    └── init_linux_server.sh   # Bash: Setup servidor Linux
```

### Requisitos Técnicos
- [ ] Terraform >= 1.3.0
- [ ] AWS Provider >= 4.44.0
- [ ] Variables con validaciones (ej: tipo_servidor_ad solo acepta "ubuntu" o "windows")
- [ ] Uso de Data Sources para obtener AMIs dinámicamente (siempre últimas versiones)
- [ ] Uso de Locals para lógica condicional compleja
- [ ] Count loops para crear múltiples subredes
- [ ] Outputs con información útil (IPs, comandos de conexión)
- [ ] Backend S3 para gestión de estado centralizada
- [ ] Tags consistentes en todos los recursos

### Requisitos de Código
- [ ] Código modular (separado en network y compute)
- [ ] Variables nombradas de forma clara (descripción en cada una)
- [ ] Comentarios explicativos en secciones complejas
- [ ] Outputs bien documentados
- [ ] Convención de nombres consistente (ej: "${var.project_name}-vpc")

---

## 📝 DOCUMENTACIÓN REQUERIDA

### 1. README.md
Debe incluir:
- Descripción general del proyecto
- Requisitos previos (AWS Account, Terraform, AWS CLI)
- Instrucciones de instalación paso a paso
- Cómo personalizar variables (región, SO del DC, etc.)
- Comandos para desplegar y destruir infraestructura
- Ejemplo de output tras apply
- Troubleshooting común

### 2. ARCHITECTURE.md
Debe incluir:
- Diagrama de arquitectura (ASCII o descripción)
- Flujo de red (tráfico de entrada/salida)
- Justificación de decisiones de diseño
- Explica por qué cada componente está donde está
- Patrones de seguridad aplicados

### 3. VARIABLES_GUIDE.md
Debe incluir:
- Explicación de cada variable de entrada
- Valores por defecto y rango permitido
- Ejemplo de terraform.tfvars customizado
- Cómo cambiar región, CIDR, etc.

### 4. MODULES_REFERENCE.md
Debe incluir:
- Documentación de cada módulo (network, compute)
- Inputs y outputs de cada módulo
- Recursos creados por cada módulo
- Dependencias entre módulos

### 5. COSTS.md
Debe incluir:
- Estimación de costos mensuales
- Desglose por tipo de recurso
- Tips para reducir costos
- Nota sobre AWS Academy (si aplica)

### 6. Documentación en el Código
- Comentarios explicativos en archivos .tf complejos
- Descripción clara en variables y outputs
- Ejemplos de uso en comentarios

---

## 🔒 REQUISITOS DE SEGURIDAD

- [ ] Servidores privados NO tienen IP pública directa (NAT Gateway)
- [ ] Clientes públicos usan Elastic IPs (fijas)
- [ ] Security Groups granulares (puerto específico, cidr específico)
- [ ] Ingress restringido: IPs privadas desde VPC, clientes desde internet
- [ ] Egress abierto (salida sin restricciones)
- [ ] Key Pair de AWS requerido (no hardcodeado)
- [ ] Estado guardado en S3 encriptado
- [ ] IPs privadas fijas para DC y servidor Linux (facilitates DNS setup)

---

## 🚀 CASOS DE USO EDUCATIVOS SOPORTADOS

Con esta infraestructura, los estudiantes pueden:

### A. Active Directory / Samba
- [ ] Crear usuarios y grupos en el DC
- [ ] Configurar políticas de grupo (GPO)
- [ ] Entender autenticación Kerberos
- [ ] Troubleshoot resolución DNS

### B. Gestión de Dominios
- [ ] Unir máquinas al dominio
- [ ] Configurar cliente LDAP
- [ ] Sincronización de credenciales

### C. Compartición de Recursos
- [ ] Compartir carpetas SMB
- [ ] Configurar permisos NTFS
- [ ] Usar servidor NFS

### D. Redes en AWS
- [ ] Entender VPC, subredes, routing
- [ ] Configurar Security Groups
- [ ] Troubleshoot conectividad
- [ ] Usar AWS Console y CLI

### E. Infrastructure as Code
- [ ] Aprender Terraform
- [ ] Automatización de infraestructura
- [ ] Gestión de estado
- [ ] Control de versiones de IaC

---

## 📊 CRITERIOS DE EVALUACIÓN

### Funcionalidad (40%)
- [ ] La infraestructura se despliega sin errores
- [ ] Todos los 5 servidores inician correctamente
- [ ] Los servidores privados pueden acceder a internet via NAT
- [ ] Los clientes públicos son accesibles desde internet
- [ ] Security Groups están bien configurados

### Código Terraform (30%)
- [ ] Estructura modular clara
- [ ] Variables y outputs documentados
- [ ] Convención de nombres consistente
- [ ] Uso correcto de Terraform (loops, conditionals, locals)
- [ ] Backend S3 correctamente configurado

### Documentación (20%)
- [ ] README claro y completo
- [ ] Documentación de arquitectura
- [ ] Guías de variables y módulos
- [ ] Ejemplos de uso
- [ ] Estimación de costos

### Automatización (10%)
- [ ] User Data scripts funcionan
- [ ] Instancias se configuran automáticamente
- [ ] Minimal manual setup requerido

---

## 📥 ENTREGABLES

```
Tu carpeta de entrega debe contener:

portcastello-ra6/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── backend.tf
├── .terraform.lock.hcl
├── tfplan (binario de plan)
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

### Archivo README Resumido (Checklist)
- [ ] Descripción del proyecto (3-5 líneas)
- [ ] Diagrama ASCII de la arquitectura
- [ ] Tabla con los 5 servidores (SO, IP, Rol)
- [ ] Requisitos previos
- [ ] Pasos para desplegar
- [ ] Pasos para destruir
- [ ] Troubleshooting (3-5 problemas comunes)

---

## ⏱️ TIMELINE SUGERIDO

| Fase | Duración | Tareas |
|------|----------|--------|
| **Planificación** | 2-3h | Entender requisitos, diseñar arquitectura |
| **Módulo Network** | 4-5h | VPC, subredes, IGW, NAT GW, route tables |
| **Módulo Compute** | 5-6h | EC2 instances, Security Groups, EIPs |
| **Automatización** | 3-4h | User Data scripts, configuración automática |
| **Documentación** | 3-4h | README, ARCHITECTURE, COSTS, etc. |
| **Testing** | 2-3h | Desplegar, probar conectividad, destruir |
| **Refinamiento** | 1-2h | Ajustes finales, optimización |

**Total:** 20-30 horas

---

## 🎓 LEARNING OUTCOMES

Al completar esta tarea, habrás aprendido:

✅ Conceptos de VPC, subredes, gateways, routing  
✅ Instancias EC2, AMIs, tipos de instancia  
✅ Security Groups y reglas de firewall  
✅ Elastic IPs para IP pública persistente  
✅ Infrastructure as Code con Terraform  
✅ Modularización y reutilización en Terraform  
✅ Data sources, locals, variables, outputs  
✅ Backend S3 para gestión de estado  
✅ User Data para automatización  
✅ Automatización de administración de sistemas  
✅ Buenas prácticas en IaC  
✅ Documentación de infraestructura  

---

## 📚 REFERENCIAS

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Active Directory Basics](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started-with-active-directory-domain-services-adds)

---

## ❓ PREGUNTAS FRECUENTES

**P: ¿Puedo usar CloudFormation en lugar de Terraform?**  
R: No, el objetivo específico es practicar Terraform. Si usas CloudFormation, será un 0.

**P: ¿Debo incluir el histórico de git?**  
R: Sí, inclúyelo. Demuestra iteración y desarrollo progresivo.

**P: ¿Los scripts deben estar funcionales al 100%?**  
R: Sí, pero si hay problemas menores, documéntalo en README.

**P: ¿Puedo cambiar los tipos de instancia?**  
R: Puedes optimizar (siempre que funcione), pero mantén t3 pequeños.

**P: ¿Y si cambio los CIDRs?**  
R: Puedes cambiarlos, pero debe funcionar correctamente (recalcula subredes).

---

## 📞 SOPORTE

Si tienes dudas:
1. Revisa la documentación de Terraform/AWS
2. Revisa el ANALISIS_DETALLADO.md de referencia
3. Consulta con el instructor

