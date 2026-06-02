# RÚBRICA DE EVALUACIÓN - PORTCASTELLO RA6

## Escala de Calificación
- **5 (Excelente):** Cumple completamente + mejoras
- **4 (Bien):** Cumple completamente  
- **3 (Aceptable):** Cumple mayormente, faltan detalles
- **2 (Insuficiente):** Cumple parcialmente, hay errores
- **1 (Deficiente):** Cumple mínimamente o incompleto
- **0 (No hecho):** No entregado o no funciona

---

## 1. FUNCIONALIDAD DE LA INFRAESTRUCTURA (40 puntos)

### 1.1 Despliegue Exitoso (10 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| `terraform init` sin errores | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| `terraform plan` sin errores | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| `terraform apply` exitoso | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Todos los 5 servidores crean | ✅ | ✅ | ✅ | 3-4 | 1-2 | 0 |
| Backend S3 funciona | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |

**Puntuación 1.1:** ___/10

---

### 1.2 Infraestructura de Red (8 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| VPC con CIDR correcto | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| 4 subredes en 2 AZ | ✅ | ✅ | ✅ | 3/4 | 2/4 | <2 |
| 2 públicas, 2 privadas | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| IGW + NAT GW funcionan | ✅ | ✅ | ✅ | 1 falta | ❌ | ❌ |
| Rutas correctas | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |

**Puntuación 1.2:** ___/8

---

### 1.3 Instancias EC2 (10 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| DC ubicado en privada | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Linux Server en privada | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Win CLI en pública | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Linux CLI en pública | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Types y almacenamiento correctos | ✅ | ✅ | ✅ | Minores | ❌ | ❌ |
| IPs privadas fijas (.10, .20) | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Elastic IPs en clientes públicos | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |

**Puntuación 1.3:** ___/10

---

### 1.4 Seguridad (Security Groups) (12 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| SG DC con puertos AD correctos | ✅ | ✅ | ✅ | Falta 1-2 | Falta >2 | ❌ |
| SG Servidor Linux correcto | ✅ | ✅ | ✅ | Falta 1 | ❌ | ❌ |
| SG Cliente Windows (RDP público) | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| SG Cliente Linux (SSH público) | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| Restricciones de CIDR correctas | ✅ | ✅ | ✅ | Menores | ❌ | ❌ |
| Egress sin restricciones | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ |
| No hay exposición innecesaria | ✅ | ✅ | ✅ | Alguna | ❌ | ❌ |

**Puntuación 1.4:** ___/12

---

**TOTAL SECCIÓN 1:** ___/40

---

## 2. CÓDIGO TERRAFORM (30 puntos)

### 2.1 Estructura y Modularidad (8 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Módulos network y compute separados | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |
| Directorios bien organizados | ✅ | ✅ | ✅ | Desordenado | ❌ | ❌ |
| main.tf limpio y legible | ✅ | ✅ | ✅ | Confuso | ❌ | ❌ |
| Files separados por responsabilidad | ✅ | ✅ | ✅ | Mezcla roles | ❌ | ❌ |
| Convención de nombres consistente | ✅ | ✅ | ✅ | Inconsistente | ❌ | ❌ |

**Puntuación 2.1:** ___/8

---

### 2.2 Variables y Outputs (7 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Variables globales bien definidas | ✅ | ✅ | ✅ | Faltan algunas | ❌ | ❌ |
| Variables con descripciones claras | ✅ | ✅ | ✅ | Vagas | ❌ | ❌ |
| Valores por defecto sensatos | ✅ | ✅ | ✅ | Algunos raros | ❌ | ❌ |
| Validaciones en variables | ✅ | ✅ | ✅ | Faltan algunas | ❌ | ❌ |
| Outputs documentados | ✅ | ✅ | ✅ | Sin desc. | ❌ | ❌ |
| terraform.tfvars correcto | ✅ | ✅ | ✅ | Incompleto | ❌ | ❌ |
| Outputs muestran IPs y comandos | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |

**Puntuación 2.2:** ___/7

---

### 2.3 Técnicas Terraform Avanzadas (8 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Data sources para AMIs dinámicas | ✅ | ✅ | ✅ | Hardcodeado | ❌ | ❌ |
| Locals para lógica condicional | ✅ | ✅ | ✅ | No usados | ❌ | ❌ |
| Count loops correctamente | ✅ | ✅ | ✅ | Incorrecto | ❌ | ❌ |
| Splat syntax donde aplica | ✅ | ✅ | ✅ | String concat | ❌ | ❌ |
| Depends_on cuando necesario | ✅ | ✅ | ✅ | Falta alguno | ❌ | ❌ |
| Backend S3 configurado | ✅ | ✅ | ✅ | Local backend | ❌ | ❌ |
| Tags consistentes | ✅ | ✅ | ✅ | Inconsistentes | ❌ | ❌ |
| Formato HCL limpio | ✅ | ✅ | ✅ | Desorganizado | ❌ | ❌ |

**Puntuación 2.3:** ___/8

---

### 2.4 Documentación en Código (7 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Comentarios explicativos | ✅ | ✅ | ✅ | Pocos | Casi nada | ❌ |
| Secciones delimitadas | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |
| Explicación de lógica complicada | ✅ | ✅ | ✅ | Incompleta | ❌ | ❌ |
| Descripciones en variables | ✅ | ✅ | ✅ | Vagas | ❌ | ❌ |
| Descripciones en outputs | ✅ | ✅ | ✅ | Vagas | ❌ | ❌ |
| No hay código muerto | ✅ | ✅ | ✅ | Algo residual | ❌ | ❌ |
| Código fácil de mantener | ✅ | ✅ | ✅ | Difícil | ❌ | ❌ |

**Puntuación 2.4:** ___/7

---

**TOTAL SECCIÓN 2:** ___/30

---

## 3. DOCUMENTACIÓN EXTERNA (20 puntos)

### 3.1 README.md (5 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Descripción clara del proyecto | ✅ | ✅ | ✅ | Vaga | ❌ | ❌ |
| Diagrama ASCII o descripción visual | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |
| Requisitos previos listados | ✅ | ✅ | ✅ | Incompletos | ❌ | ❌ |
| Pasos de instalación claros | ✅ | ✅ | ✅ | Confusos | ❌ | ❌ |
| Ejemplo de output post-apply | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |

**Puntuación 3.1:** ___/5

---

### 3.2 ARCHITECTURE.md (5 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Diagrama detallado | ✅ | ✅ | ✅ | Básico | ❌ | ❌ |
| Explicación de flujo de red | ✅ | ✅ | ✅ | Superficial | ❌ | ❌ |
| Justificación de decisiones | ✅ | ✅ | ✅ | Ausente | ❌ | ❌ |
| Patrones de seguridad explicados | ✅ | ✅ | ✅ | Poco | ❌ | ❌ |
| Tabla con servidores (SO, rol, IP) | ✅ | ✅ | ✅ | Incompleta | ❌ | ❌ |

**Puntuación 3.2:** ___/5

---

### 3.3 Guías Especializadas (VARIABLES, MODULES, COSTS) (5 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| VARIABLES_GUIDE completo | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |
| MODULES_REFERENCE completo | ✅ | ✅ | ✅ | Parcial | ❌ | ❌ |
| COSTS estimado correctamente | ✅ | ✅ | ✅ | Incorrecto | ❌ | ❌ |
| Ejemplos de configuración | ✅ | ✅ | ✅ | Falta alguno | ❌ | ❌ |
| Troubleshooting incluido | ✅ | ✅ | ✅ | Básico | ❌ | ❌ |

**Puntuación 3.3:** ___/5

---

### 3.4 Calidad de Documentación (5 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Redacción clara | ✅ | ✅ | ✅ | Confusa | ❌ | ❌ |
| Markdown bien formateado | ✅ | ✅ | ✅ | Desordenado | ❌ | ❌ |
| Tablas y diagramas | ✅ | ✅ | ✅ | Poco visual | ❌ | ❌ |
| Coherencia entre documentos | ✅ | ✅ | ✅ | Inconsistente | ❌ | ❌ |
| Fácil de seguir | ✅ | ✅ | ✅ | Complicado | ❌ | ❌ |

**Puntuación 3.4:** ___/5

---

**TOTAL SECCIÓN 3:** ___/20

---

## 4. AUTOMATIZACIÓN Y SCRIPTS (10 puntos)

### 4.1 User Data Scripts (10 puntos)

| Criterio | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|---|---|---|---|---|---|
| Script DC (Samba o Windows) | ✅ | ✅ | ✅ | Incompleto | ❌ | ❌ |
| Script Linux Server | ✅ | ✅ | ✅ | Incompleto | ❌ | ❌ |
| Script Win CLI | ✅ | ✅ | ✅ | Incompleto | ❌ | ❌ |
| Script Linux CLI | ✅ | ✅ | ✅ | Incompleto | ❌ | ❌ |
| Scripts ejecutan sin errores | ✅ | ✅ | ✅ | Algunos fallan | Muchos fallan | ❌ |
| Máquinas se configuran automáticamente | ✅ | ✅ | ✅ | Parcial | Nada | ❌ |
| Servidores se unen al dominio | ✅ | ✅ | ✅ | Parcial | No | ❌ |
| Manejo de errores en scripts | ✅ | ✅ | ✅ | Nada | ❌ | ❌ |
| Logs o salida informativos | ✅ | ✅ | ✅ | Nada | ❌ | ❌ |
| Documentación en scripts | ✅ | ✅ | ✅ | Poco | ❌ | ❌ |

**Puntuación 4.1:** ___/10

---

**TOTAL SECCIÓN 4:** ___/10

---

## CALIFICACIÓN FINAL

### Desglose de Puntos

| Sección | Puntos | Obtenido |
|---------|--------|----------|
| 1. Funcionalidad | 40 | ___/40 |
| 2. Código Terraform | 30 | ___/30 |
| 3. Documentación | 20 | ___/20 |
| 4. Automatización | 10 | ___/10 |
| **TOTAL** | **100** | **___/100** |

### Conversión a Calificación

- **90-100:** Sobresaliente (A)
- **80-89:** Notable (B)
- **70-79:** Bien (C)
- **60-69:** Aceptable (D)
- **50-59:** Insuficiente (E)
- **<50:** Suspenso (F)

**CALIFICACIÓN FINAL: ___**

---

## NOTAS DEL EVALUADOR

### Fortalezas
(Escribir aquí qué hizo bien el estudiante)

```
_____________________________________________________________

_____________________________________________________________

_____________________________________________________________
```

### Áreas de Mejora
(Escribir aquí qué puede mejorar)

```
_____________________________________________________________

_____________________________________________________________

_____________________________________________________________
```

### Feedback Adicional
(Comentarios generales, sugerencias, etc.)

```
_____________________________________________________________

_____________________________________________________________

_____________________________________________________________
```

---

**Evaluador:** _______________________  
**Fecha:** _______________________  
**Firma:** _______________________

