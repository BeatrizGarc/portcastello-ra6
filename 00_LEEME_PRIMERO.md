# 📖 ¡LEE ESTO PRIMERO!

Bienvenido al proyecto **Portcastello RA6**.

Se ha creado una **tarea educativa completa** para que students aprendan Infrastructure as Code con Terraform en AWS.

---

## 🎯 SI ERES PROFESOR

**Tiempo estimado de lectura:** 30 minutos

### Sigue estos pasos:

1. **Lee primero:** `RESUMEN_EJECUTIVO.md`
   - Entiende la estructura completa
   - Sabe cómo está organizado todo

2. **Luego lee:** `ENUNCIADO_TAREA.md`
   - Conoce exactamente qué debe hacer el estudiante
   - Puedes usarlo directamente como enunciado

3. **Revisa:** `RUBRICA_EVALUACION.md`
   - Define cómo calificarás
   - Comparte con alumnos para transparencia

4. **Consulta:** `ANALISIS_DETALLADO.md`
   - Si necesitas entender técnicamente cómo funciona
   - Para responder preguntas de alumnos

5. **Comparte con alumnos:**
   - ✅ **Obligatorio:** `ENUNCIADO_TAREA.md`
   - ✅ **Recomendado:** `RUBRICA_EVALUACION.md`
   - ⭕ **Opcional:** `QUICK_REFERENCE.md` (ayuda rápida)

---

## 🎓 SI ERES ESTUDIANTE

**Tiempo estimado de lectura:** 20 minutos

### Sigue estos pasos:

1. **Lee primero:** `QUICK_REFERENCE.md`
   - Visión rápida de la arquitectura
   - Comandos esenciales
   - Tabla de servidores

2. **Luego lee:** `ENUNCIADO_TAREA.md`
   - Sabe exactamente qué debes hacer
   - Criterios de evaluación
   - Estructura de entrega

3. **Consulta mientras trabajas:** `ANALISIS_DETALLADO.md`
   - Cuando no entiendas cómo funciona algo
   - Busca la sección relevant

4. **Antes de entregar:**
   - Autoevalúate con `RUBRICA_EVALUACION.md`
   - Asegúrate de cumplir criterios

---

## 📚 LOS 6 DOCUMENTOS CREADOS

| # | Archivo | Propósito | Páginas | Lectura |
|---|---------|----------|---------|---------|
| 1 | **ENUNCIADO_TAREA.md** | Qué debes hacer (el enunciado) | 40 | 30m |
| 2 | **ANALISIS_DETALLADO.md** | Cómo funciona cada archivo | 50 | Consulta |
| 3 | **RUBRICA_EVALUACION.md** | Cómo se evalúa | 30 | 20m |
| 4 | **RESUMEN_EJECUTIVO.md** | Guía de profesores | 25 | 15m |
| 5 | **QUICK_REFERENCE.md** | Referencia rápida de estudiante | 20 | Consulta |
| 6 | **INDICE_DOCUMENTACION.md** | Índice y navegación | 15 | 10m |

**+ Tu código actual (main.tf, modules/, scripts/)**

---

## 🚀 RESUMEN EN 60 SEGUNDOS

### El Proyecto
Desplegar una **infraestructura de Active Directory en AWS** usando Terraform.

### Lo que creas
- 1 VPC con 4 subredes
- 5 servidores EC2:
  - 1 Controlador de Dominio (DC)
  - 1 Servidor Linux (Samba)
  - 2 Clientes (Windows + Linux)
- Security Groups configurados
- Todo con Terraform

### Lo que aprendes
✅ VPC, subredes, gateways en AWS  
✅ EC2 instances, Security Groups  
✅ Infrastructure as Code (Terraform)  
✅ Modularización y buenas prácticas  
✅ Automatización (User Data scripts)  
✅ Active Directory / Samba

### Tiempo
20-30 horas totales

### Resultado
Laboratorio educativo completamente automatizado

---

## 🎯 PRÓXIMOS PASOS

### SI ERES PROFESOR:
```
1. Lee RESUMEN_EJECUTIVO.md (15 min)
2. Lee ENUNCIADO_TAREA.md (30 min)
3. Personaliza si es necesario
4. Comparte con alumnos
5. Establece fecha límite
```

### SI ERES ESTUDIANTE:
```
1. Lee QUICK_REFERENCE.md (10 min)
2. Lee ENUNCIADO_TAREA.md (30 min)
3. Entender checklist de implementación
4. Comenzar a codificar
5. Consultar ANALISIS_DETALLADO.md cuando necesites
```

---

## 📂 ESTRUCTURA DE ARCHIVOS

```
portcastello-ra6/
├── 00_LEEME_PRIMERO.md                ← ESTÁS AQUÍ
├── ENUNCIADO_TAREA.md                 ← EMPIEZA AQUÍ (estudiante)
├── ANALISIS_DETALLADO.md              ← REFERENCIA TÉCNICA
├── RUBRICA_EVALUACION.md              ← CRITERIOS
├── RESUMEN_EJECUTIVO.md               ← PARA PROFESORES
├── QUICK_REFERENCE.md                 ← CHULETA RÁPIDA
├── INDICE_DOCUMENTACION.md            ← ÍNDICE
│
├── main.tf                             ← CÓDIGO
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── backend.tf
├── .terraform.lock.hcl
│
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
│
└── scripts/
    ├── init_windows_dc.ps1
    ├── init_server_dc.sh
    ├── init_win_cli.ps1
    ├── init_linux_cli.sh
    └── init_linux_server.sh
```

---

## 🎓 WHAT YOU'LL LEARN

**Terraform Concepts:**
- Modules & modularization
- Variables, locals, outputs
- Data sources, count loops
- Backend S3, state management
- Best practices

**AWS Concepts:**
- VPC architecture
- Subnets & routing
- Security Groups
- EC2 instances
- Elastic IPs

**DevOps/SysAdmin:**
- Infrastructure as Code
- Automation with User Data
- SSH & RDP access
- Active Directory / Samba
- Domain management

---

## ⚡ QUICK START (Si ya sabes Terraform)

1. **Configura variables:**
   ```bash
   cat terraform.tfvars
   # Personaliza si es necesario
   ```

2. **Inicializa:**
   ```bash
   terraform init
   ```

3. **Verifica:**
   ```bash
   terraform plan
   ```

4. **Crea:**
   ```bash
   terraform apply
   ```

5. **Accede:**
   ```bash
   terraform output
   # Copia comando SSH o RDP
   ```

---

## 🆘 AYUDA RÁPIDA

| Pregunta | Respuesta |
|----------|----------|
| **¿Qué tengo que hacer?** | Lee `ENUNCIADO_TAREA.md` |
| **¿Cómo funciona esto?** | Lee `ANALISIS_DETALLADO.md` |
| **¿Cómo se evalúa?** | Lee `RUBRICA_EVALUACION.md` |
| **¿Comando rápido?** | Busca en `QUICK_REFERENCE.md` |
| **¿Qué sigue?** | Lee `INDICE_DOCUMENTACION.md` |

---

## ✅ CHECKLIST: Antes de Empezar

- [ ] He leído este archivo (00_LEEME_PRIMERO.md)
- [ ] He leído QUICK_REFERENCE.md (estudiante) o RESUMEN_EJECUTIVO.md (profesor)
- [ ] He entendido la arquitectura general
- [ ] Sé qué debo hacer (estudiante) o qué debo enseñar (profesor)
- [ ] Tengo acceso a AWS (Academy o credenciales)
- [ ] Tengo Terraform instalado
- [ ] Tengo acceso al código de este proyecto

---

## 📞 REFERENCIAS

- **Terraform Docs:** https://www.terraform.io/docs
- **AWS Docs:** https://docs.aws.amazon.com
- **Samba/AD:** https://www.samba.org

---

## 🎁 Bonus: Lo que está incluido

✅ **Código Terraform modular** - Listo para usar  
✅ **4 módulos de documentación** - Completos  
✅ **Scripts de automatización** - Para cada servidor  
✅ **Rúbrica objetiva** - Para evaluar justamente  
✅ **Referencia técnica** - Para entender todo  
✅ **Quick reference** - Para consulta rápida  

---

## 🚀 ¡A COMENZAR!

### Si eres PROFESOR:
→ **Abre ahora:** `RESUMEN_EJECUTIVO.md`

### Si eres ESTUDIANTE:
→ **Abre ahora:** `QUICK_REFERENCE.md`

---

## 📝 Notas Finales

1. **Los documentos están listos para usar** - No necesitan edición
2. **El código funciona** - Se ha probado
3. **Es educativo** - Enseña conceptos reales
4. **Es completo** - Nada falta
5. **Es adaptable** - Personaliza según necesites

---

**¡Bienvenido! 🎓 Que disfrutes aprendiendo Infrastructure as Code.**

Cualquier duda: consulta el documento correspondiente o el índice.

---

**Creado:** 2026-06-02  
**Proyecto:** Portcastello RA6  
**Tema:** Infrastructure as Code con Terraform y AWS  
**Nivel:** Avanzado  
**Tiempo Estimado:** 20-30 horas

