# ⚙️ Guía de Configuración - Open WebUI

Esta guía te ayudará a configurar Open WebUI según tus necesidades específicas.

## 📋 Tabla de Contenidos

1. [Variables de Entorno](#variables-de-entorno)
2. [Configuración de Base de Datos](#configuración-de-base-de-datos)
3. [APIs de Inteligencia Artificial](#apis-de-inteligencia-artificial)
4. [Autenticación y Seguridad](#autenticación-y-seguridad)
5. [Configuración de Archivos](#configuración-de-archivos)
6. [Configuración Avanzada](#configuración-avanzada)
7. [Ejemplos de Configuración](#ejemplos-de-configuración)

---

## 🌍 Variables de Entorno

### Configuración del Servidor

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `PORT` | Puerto donde se ejecuta la aplicación | `8080` | `8080` |
| `HOST` | Dirección IP del host | `0.0.0.0` | `0.0.0.0` |
| `WORKERS` | Número de workers de Uvicorn | `1` | `4` |
| `RELOAD` | Recarga automática en desarrollo | `false` | `true` |
| `DEBUG` | Modo debug | `false` | `true` |

### Configuración de Seguridad

| Variable | Descripción | Requerido | Ejemplo |
|----------|-------------|-----------|---------|
| `WEBUI_SECRET_KEY` | Clave secreta para JWT | ✅ | `mi-clave-super-secreta-123` |
| `JWT_EXPIRES_IN` | Tiempo de expiración del JWT | ❌ | `24h` |
| `SESSION_TIMEOUT` | Timeout de sesión en segundos | ❌ | `3600` |
| `ENABLE_CORS` | Habilitar CORS | ❌ | `true` |
| `CORS_ALLOW_ORIGIN` | Orígenes permitidos para CORS | ❌ | `*` |

### Configuración de Logs

| Variable | Descripción | Valor por Defecto | Opciones |
|----------|-------------|-------------------|----------|
| `LOG_LEVEL` | Nivel de logging | `INFO` | `DEBUG`, `INFO`, `WARNING`, `ERROR` |
| `LOG_FILE` | Archivo de logs | `./logs/webui.log` | Ruta del archivo |
| `ENABLE_LOGGING` | Habilitar logging | `true` | `true`, `false` |

---

## 🗄️ Configuración de Base de Datos

### SQLite (Por Defecto)

```env
DATABASE_URL=sqlite:///./data/webui.db
```

**Ventajas:**
- ✅ No requiere instalación adicional
- ✅ Perfecto para desarrollo y pruebas
- ✅ Fácil backup (un solo archivo)

**Desventajas:**
- ❌ No recomendado para producción con múltiples usuarios
- ❌ No soporta conexiones concurrentes

### PostgreSQL (Recomendado para Producción)

```env
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/webui_db
```

**Configuración completa:**

```env
# PostgreSQL
DATABASE_URL=postgresql://webui_user:secure_password@localhost:5432/webui_db
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=30
DB_POOL_TIMEOUT=30
DB_POOL_RECYCLE=3600
```

**Instalación de PostgreSQL:**

```bash
# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib

# CentOS/RHEL
sudo dnf install postgresql postgresql-server

# macOS
brew install postgresql
```

**Configuración inicial:**

```sql
-- Crear usuario y base de datos
CREATE USER webui_user WITH PASSWORD 'secure_password';
CREATE DATABASE webui_db OWNER webui_user;
GRANT ALL PRIVILEGES ON DATABASE webui_db TO webui_user;
```

### MySQL/MariaDB

```env
DATABASE_URL=mysql://usuario:contraseña@localhost:3306/webui_db
```

**Configuración completa:**

```env
# MySQL
DATABASE_URL=mysql://webui_user:secure_password@localhost:3306/webui_db?charset=utf8mb4
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=30
```

---

## 🤖 APIs de Inteligencia Artificial

### OpenAI

```env
# OpenAI Configuration
OPENAI_API_KEY=sk-tu-clave-openai-aqui
OPENAI_API_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL_DEFAULT=gpt-4
OPENAI_MAX_TOKENS=4096
OPENAI_TEMPERATURE=0.7
```

**Modelos disponibles:**
- `gpt-4` - Más potente, más caro
- `gpt-3.5-turbo` - Equilibrio precio/rendimiento
- `gpt-4-turbo` - Versión optimizada de GPT-4

### Anthropic (Claude)

```env
# Anthropic Configuration
ANTHROPIC_API_KEY=tu-clave-anthropic-aqui
ANTHROPIC_MODEL_DEFAULT=claude-3-sonnet-20240229
ANTHROPIC_MAX_TOKENS=4096
```

**Modelos disponibles:**
- `claude-3-opus-20240229` - Más potente
- `claude-3-sonnet-20240229` - Equilibrado
- `claude-3-haiku-20240307` - Más rápido

### Google AI

```env
# Google AI Configuration
GOOGLE_API_KEY=tu-clave-google-aqui
GOOGLE_MODEL_DEFAULT=gemini-pro
GOOGLE_MAX_TOKENS=2048
```

### Azure OpenAI

```env
# Azure OpenAI Configuration
AZURE_OPENAI_API_KEY=tu-clave-azure
AZURE_OPENAI_ENDPOINT=https://tu-recurso.openai.azure.com/
AZURE_OPENAI_API_VERSION=2023-12-01-preview
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
```

### Ollama (Modelos Locales)

```env
# Ollama Configuration
OLLAMA_BASE_URL=http://localhost:11434
ENABLE_OLLAMA_API=true
OLLAMA_MODEL_DEFAULT=llama2
```

**Instalación de Ollama:**

```bash
# Instalar Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Descargar modelo
ollama pull llama2
ollama pull codellama
ollama pull mistral
```

---

## 🔐 Autenticación y Seguridad

### Configuración de Usuarios

```env
# User Configuration
ENABLE_SIGNUP=true
DEFAULT_USER_ROLE=user
ENABLE_LOGIN_FORM=true
ENABLE_COMMUNITY_SHARING=false
REQUIRE_EMAIL_VERIFICATION=false
```

### Roles de Usuario

| Rol | Permisos |
|-----|----------|
| `admin` | Acceso completo, gestión de usuarios |
| `user` | Uso normal de la aplicación |
| `readonly` | Solo lectura |

### Usuario Administrador por Defecto

```env
# Default Admin User
ADMIN_USER_EMAIL=admin@example.com
ADMIN_USER_PASSWORD=admin123
ADMIN_USER_NAME=Administrator
```

### Configuración OAuth (Opcional)

```env
# Google OAuth
GOOGLE_CLIENT_ID=tu-client-id
GOOGLE_CLIENT_SECRET=tu-client-secret

# GitHub OAuth
GITHUB_CLIENT_ID=tu-client-id
GITHUB_CLIENT_SECRET=tu-client-secret

# Microsoft OAuth
MICROSOFT_CLIENT_ID=tu-client-id
MICROSOFT_CLIENT_SECRET=tu-client-secret
```

### LDAP (Opcional)

```env
# LDAP Configuration
ENABLE_LDAP=true
LDAP_SERVER=ldap://tu-servidor-ldap:389
LDAP_BIND_DN=cn=admin,dc=example,dc=com
LDAP_BIND_PASSWORD=password
LDAP_USER_BASE=ou=users,dc=example,dc=com
LDAP_USER_FILTER=(uid={username})
```

---

## 📁 Configuración de Archivos

### Subida de Archivos

```env
# File Upload Configuration
MAX_UPLOAD_SIZE=100MB
UPLOAD_DIR=./uploads
ALLOWED_FILE_TYPES=pdf,txt,docx,xlsx,pptx,csv,md
ENABLE_FILE_UPLOAD=true
```

### Procesamiento de Documentos

```env
# Document Processing
ENABLE_RAG=true
ENABLE_OCR=true
OCR_ENGINE=tesseract
ENABLE_DOCUMENT_PARSING=true
```

### Almacenamiento en la Nube

#### AWS S3

```env
# AWS S3 Configuration
AWS_ACCESS_KEY_ID=tu-access-key
AWS_SECRET_ACCESS_KEY=tu-secret-key
AWS_S3_BUCKET=tu-bucket
AWS_S3_REGION=us-east-1
ENABLE_S3_STORAGE=true
```

#### Google Cloud Storage

```env
# Google Cloud Storage
GOOGLE_CLOUD_PROJECT=tu-proyecto
GOOGLE_CLOUD_BUCKET=tu-bucket
GOOGLE_APPLICATION_CREDENTIALS=./path/to/credentials.json
ENABLE_GCS_STORAGE=true
```

#### Azure Blob Storage

```env
# Azure Blob Storage
AZURE_STORAGE_ACCOUNT=tu-cuenta
AZURE_STORAGE_KEY=tu-clave
AZURE_STORAGE_CONTAINER=tu-contenedor
ENABLE_AZURE_STORAGE=true
```

---

## 🔧 Configuración Avanzada

### Redis (Cache y Sesiones)

```env
# Redis Configuration
REDIS_URL=redis://localhost:6379/0
REDIS_PASSWORD=tu-password
ENABLE_REDIS_CACHE=true
CACHE_TTL=3600
SESSION_STORE=redis
```

### Configuración de Proxy

```env
# Proxy Configuration
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=https://proxy.example.com:8080
NO_PROXY=localhost,127.0.0.1,.local
```

### Webhooks

```env
# Webhook Configuration
WEBHOOK_URL=https://tu-webhook.com/endpoint
ENABLE_WEBHOOKS=true
WEBHOOK_SECRET=tu-secret-webhook
WEBHOOK_EVENTS=user_created,chat_completed
```

### Analytics

```env
# Analytics Configuration
GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX
ENABLE_ANALYTICS=true
ENABLE_USER_TRACKING=false
```

### Backup Automático

```env
# Backup Configuration
BACKUP_DIR=./backups
AUTO_BACKUP=true
BACKUP_INTERVAL=24h
BACKUP_RETENTION_DAYS=30
ENABLE_S3_BACKUP=false
```

### Rate Limiting

```env
# Rate Limiting
ENABLE_RATE_LIMITING=true
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=3600
RATE_LIMIT_STORAGE=redis
```

---

## 📝 Ejemplos de Configuración

### Configuración para Desarrollo

```env
# .env.development
DEBUG=true
LOG_LEVEL=DEBUG
RELOAD=true
PORT=8080
HOST=0.0.0.0

# Base de datos local
DATABASE_URL=sqlite:///./data/webui_dev.db

# Seguridad relajada para desarrollo
WEBUI_SECRET_KEY=dev-secret-key
ENABLE_SIGNUP=true
ENABLE_CORS=true
CORS_ALLOW_ORIGIN=*

# APIs de prueba
OPENAI_API_KEY=sk-test-key
```

### Configuración para Producción

```env
# .env.production
DEBUG=false
LOG_LEVEL=INFO
WORKERS=4
PORT=8080
HOST=0.0.0.0

# Base de datos PostgreSQL
DATABASE_URL=postgresql://webui_user:secure_password@db:5432/webui_db

# Seguridad estricta
WEBUI_SECRET_KEY=super-secure-production-key-with-64-characters-minimum
ENABLE_SIGNUP=false
ENABLE_CORS=true
CORS_ALLOW_ORIGIN=https://tu-dominio.com

# Redis para cache
REDIS_URL=redis://redis:6379/0
ENABLE_REDIS_CACHE=true

# APIs de producción
OPENAI_API_KEY=sk-real-production-key
ANTHROPIC_API_KEY=real-anthropic-key

# Backup automático
AUTO_BACKUP=true
BACKUP_INTERVAL=6h
ENABLE_S3_BACKUP=true
AWS_S3_BUCKET=webui-backups
```

### Configuración para Docker

```env
# .env.docker
PORT=8080
HOST=0.0.0.0
WORKERS=2

# Base de datos en contenedor
DATABASE_URL=postgresql://webui_user:webui_password@postgres:5432/webui_db

# Redis en contenedor
REDIS_URL=redis://redis:6379/0

# Volúmenes Docker
UPLOAD_DIR=/app/backend/uploads
LOG_FILE=/app/backend/logs/webui.log
BACKUP_DIR=/app/backend/backups
```

### Configuración para Kubernetes

```env
# .env.kubernetes
PORT=8080
HOST=0.0.0.0
WORKERS=4

# Base de datos externa
DATABASE_URL=postgresql://webui_user:password@postgres-service:5432/webui_db

# Redis externo
REDIS_URL=redis://redis-service:6379/0

# Configuración de cluster
ENABLE_HEALTH_CHECK=true
HEALTH_CHECK_INTERVAL=30
```

---

## 🔍 Validación de Configuración

### Script de Validación

Crea un archivo `validate_config.py`:

```python
#!/usr/bin/env python3
import os
import sys
from urllib.parse import urlparse

def validate_config():
    errors = []
    warnings = []
    
    # Validar variables requeridas
    required_vars = ['WEBUI_SECRET_KEY', 'DATABASE_URL']
    for var in required_vars:
        if not os.getenv(var):
            errors.append(f"Variable requerida faltante: {var}")
    
    # Validar formato de DATABASE_URL
    db_url = os.getenv('DATABASE_URL')
    if db_url:
        parsed = urlparse(db_url)
        if not parsed.scheme:
            errors.append("DATABASE_URL debe incluir el esquema (sqlite://, postgresql://, etc.)")
    
    # Validar puerto
    port = os.getenv('PORT', '8080')
    try:
        port_int = int(port)
        if port_int < 1 or port_int > 65535:
            errors.append(f"Puerto inválido: {port}")
    except ValueError:
        errors.append(f"Puerto debe ser un número: {port}")
    
    # Validar clave secreta
    secret_key = os.getenv('WEBUI_SECRET_KEY')
    if secret_key and len(secret_key) < 32:
        warnings.append("WEBUI_SECRET_KEY debería tener al menos 32 caracteres")
    
    # Mostrar resultados
    if errors:
        print("❌ Errores de configuración:")
        for error in errors:
            print(f"  - {error}")
    
    if warnings:
        print("⚠️  Advertencias:")
        for warning in warnings:
            print(f"  - {warning}")
    
    if not errors and not warnings:
        print("✅ Configuración válida")
    
    return len(errors) == 0

if __name__ == "__main__":
    # Cargar archivo .env si existe
    if os.path.exists('.env'):
        with open('.env') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value
    
    if not validate_config():
        sys.exit(1)
```

Ejecutar validación:

```bash
python validate_config.py
```

---

## 🚨 Solución de Problemas de Configuración

### Problemas Comunes

#### Error: Variable de Entorno No Encontrada

```bash
# Verificar variables cargadas
env | grep WEBUI

# Cargar archivo .env manualmente
export $(cat .env | xargs)
```

#### Error: Base de Datos No Accesible

```bash
# Verificar conexión PostgreSQL
psql -h localhost -U webui_user -d webui_db -c "SELECT 1;"

# Verificar conexión MySQL
mysql -h localhost -u webui_user -p webui_db -e "SELECT 1;"
```

#### Error: Redis No Disponible

```bash
# Verificar conexión Redis
redis-cli ping

# Verificar con autenticación
redis-cli -a tu-password ping
```

### Herramientas de Debugging

```bash
# Ver configuración actual
python -c "
import os
from config import *
print('Configuración cargada correctamente')
for key, value in os.environ.items():
    if 'WEBUI' in key or 'DATABASE' in key:
        print(f'{key}={value}')
"

# Verificar conexión a base de datos
python -c "
from sqlalchemy import create_engine
from config import DATABASE_URL
engine = create_engine(DATABASE_URL)
with engine.connect() as conn:
    result = conn.execute('SELECT 1')
    print('Conexión a base de datos exitosa')
"
```

---

## 📚 Recursos Adicionales

- [🔐 Guía de Seguridad](./security.md)
- [🚀 Guía de Despliegue](./deployment.md)
- [📊 Configuración de Monitoreo](./monitoring.md)
- [🤖 Configuración de Modelos de IA](./ai-models.md)

---

¿Necesitas ayuda con la configuración? [Abre un issue](https://github.com/ANDYELPINGON/open-web-ui-/issues) o consulta nuestra [documentación completa](./README.md).