# 🚀 Open WebUI - Interfaz Web Avanzada para IA

<div align="center">

![Open WebUI Logo](./static/logo.png)

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green.svg)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)

**Una interfaz web moderna y potente para interactuar con modelos de IA**

[🚀 Instalación Rápida](#instalación-rápida) • [📖 Documentación](#documentación) • [🐳 Docker](#docker) • [🛠️ Desarrollo](#desarrollo)

</div>

---

## ✨ Características

- 🎨 **Interfaz Moderna**: Diseño limpio y responsive
- 🤖 **Múltiples Modelos**: Soporte para OpenAI, Anthropic, Google AI y más
- 🔐 **Autenticación Segura**: Sistema de usuarios con JWT
- 📁 **Gestión de Archivos**: Subida y procesamiento de documentos
- 🌐 **API REST**: Endpoints completos para integración
- 🐳 **Docker Ready**: Despliegue fácil con contenedores
- 🔧 **Configurable**: Múltiples opciones de configuración
- 📊 **Monitoreo**: Logs y métricas integradas

## 🚀 Instalación Rápida

### Opción 1: Instalación Automática (Recomendada)

```bash
# Clona el repositorio
git clone https://github.com/ANDYELPINGON/open-web-ui-.git
cd open-web-ui-

# Ejecuta el script de instalación automática
chmod +x install.sh
./install.sh
```

### Opción 2: Instalación Manual

#### Prerrequisitos

- Python 3.11 o superior
- pip (gestor de paquetes de Python)
- Git

#### Pasos de Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/ANDYELPINGON/open-web-ui-.git
   cd open-web-ui-
   ```

2. **Crea un entorno virtual**
   ```bash
   python -m venv venv
   
   # En Linux/macOS
   source venv/bin/activate
   
   # En Windows
   venv\Scripts\activate
   ```

3. **Instala las dependencias**
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. **Configura las variables de entorno**
   ```bash
   cp .env.example .env
   # Edita el archivo .env con tus configuraciones
   ```

5. **Inicializa la base de datos**
   ```bash
   python -c "from main import init_db; init_db()"
   ```

6. **Inicia la aplicación**
   ```bash
   # Linux/macOS
   ./start.sh
   
   # Windows
   start_windows.bat
   
   # O manualmente
   python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
   ```

7. **Accede a la aplicación**
   
   Abre tu navegador y ve a: `http://localhost:8080`

## 🐳 Docker

### Instalación con Docker (Más Fácil)

```bash
# Usando Docker Compose
docker-compose up -d

# O usando Docker directamente
docker run -d \
  --name open-webui \
  -p 8080:8080 \
  -v open-webui:/app/backend/data \
  -e WEBUI_SECRET_KEY=your-secret-key \
  open-webui:latest
```

### Construcción de la Imagen

```bash
# Construir la imagen
docker build -t open-webui .

# Ejecutar el contenedor
docker run -p 8080:8080 open-webui
```

## ⚙️ Configuración

### Variables de Entorno Principales

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `PORT` | Puerto de la aplicación | `8080` |
| `HOST` | Host de la aplicación | `0.0.0.0` |
| `WEBUI_SECRET_KEY` | Clave secreta para JWT | Auto-generada |
| `DATABASE_URL` | URL de la base de datos | SQLite local |
| `OPENAI_API_KEY` | Clave API de OpenAI | - |
| `ANTHROPIC_API_KEY` | Clave API de Anthropic | - |

### Archivo de Configuración

Crea un archivo `.env` en la raíz del proyecto:

```env
# Configuración del servidor
PORT=8080
HOST=0.0.0.0
WEBUI_SECRET_KEY=tu-clave-secreta-muy-segura

# APIs de IA
OPENAI_API_KEY=sk-tu-clave-openai
ANTHROPIC_API_KEY=tu-clave-anthropic
GOOGLE_API_KEY=tu-clave-google

# Base de datos
DATABASE_URL=sqlite:///./data/webui.db

# Configuraciones adicionales
ENABLE_SIGNUP=true
DEFAULT_USER_ROLE=user
MAX_UPLOAD_SIZE=100MB
```

## 🛠️ Desarrollo

### Configuración del Entorno de Desarrollo

1. **Instala dependencias de desarrollo**
   ```bash
   pip install -r requirements-dev.txt
   ```

2. **Configura pre-commit hooks**
   ```bash
   pre-commit install
   ```

3. **Ejecuta en modo desarrollo**
   ```bash
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
   ```

### Estructura del Proyecto

```
open-web-ui-/
├── main.py              # Aplicación principal FastAPI
├── config.py            # Configuraciones
├── constants.py         # Constantes
├── requirements.txt     # Dependencias Python
├── start.sh            # Script de inicio Linux/macOS
├── start_windows.bat   # Script de inicio Windows
├── install.sh          # Script de instalación automática
├── docs/               # Documentación
├── static/             # Archivos estáticos (CSS, JS, imágenes)
├── templates/          # Plantillas HTML
├── tests/              # Pruebas
└── kubernetes/         # Configuraciones K8s
```

### Ejecutar Pruebas

```bash
# Ejecutar todas las pruebas
pytest

# Ejecutar con cobertura
pytest --cov=. --cov-report=html

# Ejecutar pruebas específicas
pytest tests/test_api.py
```

## 📚 Documentación

- [📖 Documentación Completa](./docs/README.md)
- [🔧 Guía de Configuración](./docs/configuration.md)
- [🚀 Guía de Despliegue](./docs/deployment.md)
- [🛡️ Seguridad](./docs/SECURITY.md)
- [🤝 Contribuir](./docs/CONTRIBUTING.md)

## 🌐 API

La aplicación expone una API REST completa. Una vez iniciada, puedes acceder a:

- **Documentación Swagger**: `http://localhost:8080/docs`
- **Documentación ReDoc**: `http://localhost:8080/redoc`
- **OpenAPI Schema**: `http://localhost:8080/openapi.json`

### Endpoints Principales

- `GET /` - Página principal
- `POST /api/v1/auth/signin` - Iniciar sesión
- `POST /api/v1/auth/signup` - Registrarse
- `GET /api/v1/models` - Listar modelos disponibles
- `POST /api/v1/chat/completions` - Chat con IA
- `POST /api/v1/files/upload` - Subir archivos

## 🚀 Despliegue en Producción

### Usando Docker Compose

```yaml
version: '3.8'
services:
  open-webui:
    image: open-webui:latest
    ports:
      - "8080:8080"
    environment:
      - WEBUI_SECRET_KEY=your-production-secret
      - DATABASE_URL=postgresql://user:pass@db:5432/webui
    volumes:
      - ./data:/app/backend/data
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=webui
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Usando Kubernetes

```bash
# Aplicar configuraciones de Kubernetes
kubectl apply -f kubernetes/manifest/
```

## 🔧 Solución de Problemas

### Problemas Comunes

1. **Error de puerto en uso**
   ```bash
   # Cambiar el puerto
   export PORT=8081
   ./start.sh
   ```

2. **Error de dependencias**
   ```bash
   # Reinstalar dependencias
   pip install --upgrade -r requirements.txt
   ```

3. **Error de base de datos**
   ```bash
   # Reinicializar base de datos
   rm -f data/webui.db
   python -c "from main import init_db; init_db()"
   ```

4. **Error de permisos**
   ```bash
   # Dar permisos de ejecución
   chmod +x start.sh install.sh
   ```

### Logs y Debugging

```bash
# Ver logs en tiempo real
tail -f logs/webui.log

# Ejecutar en modo debug
export LOG_LEVEL=DEBUG
python main.py
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor lee nuestra [Guía de Contribución](./docs/CONTRIBUTING.md).

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- [FastAPI](https://fastapi.tiangolo.com/) - Framework web moderno
- [OpenAI](https://openai.com/) - APIs de IA
- [Anthropic](https://anthropic.com/) - Claude AI
- [Todos los contribuidores](https://github.com/ANDYELPINGON/open-web-ui-/contributors)

## 📞 Soporte

- 🐛 [Reportar Bug](https://github.com/ANDYELPINGON/open-web-ui-/issues)
- 💡 [Solicitar Feature](https://github.com/ANDYELPINGON/open-web-ui-/issues)
- 💬 [Discusiones](https://github.com/ANDYELPINGON/open-web-ui-/discussions)

---

<div align="center">

**⭐ Si te gusta este proyecto, ¡dale una estrella en GitHub! ⭐**

Hecho con ❤️ por [ANDYELPINGON](https://github.com/ANDYELPINGON)

</div>