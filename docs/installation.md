# 📦 Guía Completa de Instalación - Open WebUI

Esta guía te llevará paso a paso a través de diferentes métodos de instalación para Open WebUI.

## 🎯 Métodos de Instalación

1. [Instalación Automática](#instalación-automática) ⭐ **Recomendado**
2. [Instalación Manual](#instalación-manual)
3. [Docker](#docker)
4. [Docker Compose](#docker-compose)
5. [Kubernetes](#kubernetes)
6. [Instalación en Desarrollo](#instalación-en-desarrollo)

---

## 🚀 Instalación Automática

La forma más fácil y rápida de instalar Open WebUI.

### Prerrequisitos Mínimos

- **Sistema Operativo**: Linux, macOS, o Windows (con WSL)
- **RAM**: 4GB mínimo, 8GB recomendado
- **Espacio en Disco**: 2GB libres
- **Conexión a Internet**: Para descargar dependencias

### Instalación en Una Línea

```bash
curl -fsSL https://raw.githubusercontent.com/ANDYELPINGON/open-web-ui-/main/install.sh | bash
```

O descarga y ejecuta manualmente:

```bash
git clone https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-
chmod +x install.sh
./install.sh
```

### ¿Qué hace el script automático?

1. ✅ Verifica que Python 3.11+ esté instalado
2. ✅ Crea un entorno virtual
3. ✅ Instala todas las dependencias
4. ✅ Configura la base de datos
5. ✅ Crea archivos de configuración
6. ✅ Genera scripts de inicio
7. ✅ Verifica que todo funcione

---

## 🔧 Instalación Manual

Para usuarios que prefieren control total sobre el proceso.

### Paso 1: Verificar Prerrequisitos

```bash
# Verificar Python
python3 --version  # Debe ser 3.11 o superior

# Verificar pip
pip3 --version

# Verificar git
git --version
```

### Paso 2: Clonar el Repositorio

```bash
git clone https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-
```

### Paso 3: Crear Entorno Virtual

```bash
# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
# En Linux/macOS:
source venv/bin/activate

# En Windows:
venv\Scripts\activate
```

### Paso 4: Instalar Dependencias

```bash
# Actualizar pip
pip install --upgrade pip

# Instalar dependencias
pip install -r requirements.txt
```

### Paso 5: Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar configuración
nano .env  # o tu editor preferido
```

Configuración mínima en `.env`:

```env
PORT=8080
HOST=0.0.0.0
WEBUI_SECRET_KEY=tu-clave-secreta-aqui
DATABASE_URL=sqlite:///./data/webui.db
```

### Paso 6: Crear Directorios

```bash
mkdir -p data logs uploads static
```

### Paso 7: Inicializar Base de Datos

```bash
python -c "
import sys
sys.path.append('.')
from main import app
print('Base de datos inicializada')
"
```

### Paso 8: Iniciar la Aplicación

```bash
# Método 1: Usando el script
./start.sh

# Método 2: Directamente con uvicorn
python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

---

## 🐳 Docker

Instalación usando Docker para un entorno aislado.

### Instalación Rápida

```bash
docker run -d \
  --name open-webui \
  -p 8080:8080 \
  -v open-webui-data:/app/backend/data \
  -e WEBUI_SECRET_KEY=tu-clave-secreta \
  open-webui:latest
```

### Construcción Local

```bash
# Clonar repositorio
git clone https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-

# Construir imagen
docker build -t open-webui .

# Ejecutar contenedor
docker run -d \
  --name open-webui \
  -p 8080:8080 \
  -v $(pwd)/data:/app/backend/data \
  -v $(pwd)/.env:/app/.env \
  open-webui
```

### Variables de Entorno para Docker

```bash
docker run -d \
  --name open-webui \
  -p 8080:8080 \
  -e PORT=8080 \
  -e HOST=0.0.0.0 \
  -e WEBUI_SECRET_KEY=tu-clave-secreta \
  -e OPENAI_API_KEY=sk-tu-clave-openai \
  -e DATABASE_URL=sqlite:///./data/webui.db \
  -v open-webui-data:/app/backend/data \
  open-webui:latest
```

---

## 🐙 Docker Compose

Para un despliegue completo con base de datos y servicios adicionales.

### Instalación Básica

```bash
# Clonar repositorio
git clone https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-

# Crear archivo de entorno
cp .env.example .env
# Editar .env con tus configuraciones

# Iniciar servicios
docker-compose up -d
```

### Con PostgreSQL y Redis

```bash
# Iniciar con base de datos completa
docker-compose --profile production up -d
```

### Con Ollama (Modelos Locales)

```bash
# Iniciar con Ollama para modelos locales
docker-compose --profile with-ollama up -d
```

### Con Monitoreo

```bash
# Iniciar con Prometheus y Grafana
docker-compose --profile monitoring up -d
```

### Comandos Útiles

```bash
# Ver logs
docker-compose logs -f open-webui

# Reiniciar servicios
docker-compose restart

# Actualizar
docker-compose pull
docker-compose up -d

# Parar servicios
docker-compose down

# Parar y eliminar volúmenes
docker-compose down -v
```

---

## ☸️ Kubernetes

Para despliegues en producción escalables.

### Prerrequisitos

- Cluster de Kubernetes funcionando
- kubectl configurado
- Helm 3.x (opcional)

### Instalación con Manifiestos

```bash
# Aplicar configuraciones
kubectl apply -f kubernetes/manifest/

# Verificar despliegue
kubectl get pods -l app=open-webui

# Obtener URL del servicio
kubectl get service open-webui
```

### Instalación con Helm

```bash
# Añadir repositorio
helm repo add open-webui ./kubernetes/helm

# Instalar
helm install open-webui open-webui/open-webui \
  --set image.tag=latest \
  --set service.type=LoadBalancer
```

### Configuración Personalizada

```yaml
# values.yaml
replicaCount: 3

image:
  repository: open-webui
  tag: latest

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  hosts:
    - host: webui.example.com
      paths:
        - path: /
          pathType: Prefix

env:
  WEBUI_SECRET_KEY: "tu-clave-secreta"
  OPENAI_API_KEY: "sk-tu-clave"
```

```bash
helm install open-webui open-webui/open-webui -f values.yaml
```

---

## 🛠️ Instalación en Desarrollo

Para contribuidores y desarrolladores.

### Configuración Completa

```bash
# Clonar con submódulos
git clone --recursive https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias de desarrollo
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Instalar pre-commit hooks
pre-commit install

# Configurar variables de entorno para desarrollo
cp .env.example .env.dev
```

### Variables de Entorno para Desarrollo

```env
# .env.dev
DEBUG=true
LOG_LEVEL=DEBUG
RELOAD=true
PORT=8080
HOST=0.0.0.0
WEBUI_SECRET_KEY=dev-secret-key
DATABASE_URL=sqlite:///./data/webui_dev.db
```

### Ejecutar en Modo Desarrollo

```bash
# Cargar variables de desarrollo
export $(cat .env.dev | xargs)

# Iniciar con recarga automática
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### Herramientas de Desarrollo

```bash
# Formatear código
black .

# Verificar estilo
flake8 .

# Ejecutar pruebas
pytest

# Ejecutar con cobertura
pytest --cov=. --cov-report=html

# Generar documentación
mkdocs serve
```

---

## 🔍 Verificación de Instalación

### Verificar que la Aplicación Funciona

1. **Acceder a la aplicación**: `http://localhost:8080`
2. **Verificar API**: `http://localhost:8080/docs`
3. **Verificar salud**: `http://localhost:8080/health`

### Comandos de Verificación

```bash
# Verificar proceso
ps aux | grep uvicorn

# Verificar puerto
netstat -tlnp | grep 8080

# Verificar logs
tail -f logs/webui.log

# Verificar base de datos
sqlite3 data/webui.db ".tables"
```

### Pruebas Básicas

```bash
# Probar endpoint de salud
curl http://localhost:8080/health

# Probar API
curl -X GET http://localhost:8080/api/v1/models

# Probar con autenticación
curl -X POST http://localhost:8080/api/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

---

## 🚨 Solución de Problemas

### Problemas Comunes

#### Error: Puerto en Uso

```bash
# Encontrar proceso usando el puerto
lsof -i :8080

# Matar proceso
kill -9 <PID>

# O cambiar puerto
export PORT=8081
```

#### Error: Python no Encontrado

```bash
# En Ubuntu/Debian
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-pip

# En CentOS/RHEL
sudo dnf install python3.11 python3.11-pip

# En macOS
brew install python@3.11
```

#### Error: Dependencias

```bash
# Limpiar cache de pip
pip cache purge

# Reinstalar dependencias
pip install --force-reinstall -r requirements.txt

# Actualizar pip
pip install --upgrade pip setuptools wheel
```

#### Error: Base de Datos

```bash
# Eliminar base de datos corrupta
rm -f data/webui.db

# Reinicializar
python -c "from main import app; print('DB reinicializada')"
```

#### Error: Permisos

```bash
# Dar permisos a scripts
chmod +x start.sh install.sh

# Cambiar propietario de archivos
sudo chown -R $USER:$USER .
```

### Logs y Debugging

```bash
# Ver logs en tiempo real
tail -f logs/webui.log

# Ejecutar en modo debug
export LOG_LEVEL=DEBUG
python main.py

# Verificar configuración
python -c "from config import *; print('Config OK')"
```

---

## 📞 Obtener Ayuda

Si tienes problemas con la instalación:

1. 📖 Consulta la [documentación completa](./README.md)
2. 🐛 [Reporta un bug](https://github.com/ANDYELPINGON/open-web-ui-/issues)
3. 💬 [Únete a las discusiones](https://github.com/ANDYELPINGON/open-web-ui-/discussions)
4. 📧 Contacta al mantenedor

---

## ✅ Próximos Pasos

Una vez instalado exitosamente:

1. 🔐 [Configurar autenticación](./authentication.md)
2. 🤖 [Configurar modelos de IA](./ai-models.md)
3. 🎨 [Personalizar la interfaz](./customization.md)
4. 🚀 [Desplegar en producción](./deployment.md)
5. 📊 [Configurar monitoreo](./monitoring.md)

¡Disfruta usando Open WebUI! 🎉