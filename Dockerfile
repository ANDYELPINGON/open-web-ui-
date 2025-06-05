# 🚀 Open WebUI - Dockerfile Optimizado
FROM python:3.11-slim

# Metadatos
LABEL maintainer="ANDYELPINGON <andyelpingon@example.com>"
LABEL description="Open WebUI - Interfaz Web Avanzada para IA"
LABEL version="1.0.0"

# Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# Crear usuario no-root para seguridad
RUN groupadd -r webui && useradd -r -g webui webui

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libopencv-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Crear directorios de trabajo
WORKDIR /app
RUN mkdir -p /app/backend/data \
             /app/backend/uploads \
             /app/backend/logs \
             /app/backend/static \
    && chown -R webui:webui /app

# Copiar archivos de dependencias
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Instalar Playwright browsers si es necesario
RUN playwright install chromium && \
    playwright install-deps chromium

# Copiar código de la aplicación
COPY . .

# Copiar archivos estáticos
COPY static/ /app/backend/static/

# Configurar permisos
RUN chown -R webui:webui /app && \
    chmod +x start.sh

# Cambiar a usuario no-root
USER webui

# Crear directorios de datos con permisos correctos
RUN mkdir -p /app/backend/data/uploads \
             /app/backend/data/logs \
             /app/backend/data/cache

# Exponer puerto
EXPOSE 8080

# Configurar variables de entorno por defecto
ENV PORT=8080 \
    HOST=0.0.0.0 \
    WEBUI_SECRET_KEY="" \
    DATABASE_URL="sqlite:///./data/webui.db" \
    LOG_LEVEL="INFO"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Comando por defecto
CMD ["./start.sh"]

# Etiquetas adicionales
LABEL org.opencontainers.image.source="https://github.com/ANDYELPINGON/open-web-ui-"
LABEL org.opencontainers.image.documentation="https://github.com/ANDYELPINGON/open-web-ui-/blob/main/README.md"
LABEL org.opencontainers.image.licenses="MIT"