#!/bin/bash

# 🚀 Open WebUI - Script de Inicio Mejorado
# Este script inicia Open WebUI con configuraciones optimizadas

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_color() {
    printf "${1}${2}${NC}\n"
}

# Banner de inicio
print_color $CYAN "
 ██████╗ ██████╗ ███████╗███╗   ██╗    ██╗    ██╗███████╗██████╗ ██╗   ██╗██╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║    ██║    ██║██╔════╝██╔══██╗██║   ██║██║
██║   ██║██████╔╝█████╗  ██╔██╗ ██║    ██║ █╗ ██║█████╗  ██████╔╝██║   ██║██║
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══╝  ██╔══██╗██║   ██║██║
╚██████╔╝██║     ███████╗██║ ╚████║    ╚███╔███╔╝███████╗██████╔╝╚██████╔╝██║
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝
"

print_color $GREEN "🚀 Iniciando Open WebUI..."
echo

# Verificar si estamos en el directorio correcto
if [ ! -f "main.py" ]; then
    print_color $RED "❌ Error: No se encontró main.py"
    print_color $RED "   Asegúrate de ejecutar este script desde el directorio raíz del proyecto"
    exit 1
fi

# Detectar sistema operativo
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

print_color $BLUE "🖥️  Sistema detectado: $OS"

# Activar entorno virtual si existe
if [ -d "venv" ]; then
    print_color $YELLOW "📦 Activando entorno virtual..."
    
    if [ "$OS" = "windows" ]; then
        source venv/Scripts/activate
    else
        source venv/bin/activate
    fi
    
    print_color $GREEN "✅ Entorno virtual activado"
else
    print_color $YELLOW "⚠️  No se encontró entorno virtual. Usando Python del sistema."
fi

# Cargar variables de entorno
if [ -f ".env" ]; then
    print_color $YELLOW "⚙️  Cargando configuración desde .env..."
    export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)
    print_color $GREEN "✅ Configuración cargada"
else
    print_color $YELLOW "⚠️  No se encontró archivo .env. Usando configuración por defecto."
fi

# Configurar variables por defecto
export PORT=${PORT:-8080}
export HOST=${HOST:-0.0.0.0}
export LOG_LEVEL=${LOG_LEVEL:-INFO}
export UVICORN_WORKERS=${UVICORN_WORKERS:-1}

# Verificar dependencias críticas
print_color $YELLOW "🔍 Verificando dependencias..."

python -c "
import sys
try:
    import fastapi, uvicorn, pydantic
    print('✅ Dependencias principales OK')
except ImportError as e:
    print(f'❌ Error: {e}')
    print('💡 Ejecuta: pip install -r requirements.txt')
    sys.exit(1)
" || exit 1

# Verificar que se puede cargar la aplicación
python -c "
import sys
sys.path.append('.')
try:
    from main import app
    print('✅ Aplicación cargada correctamente')
except Exception as e:
    print(f'❌ Error al cargar aplicación: {e}')
    sys.exit(1)
" || exit 1

# Crear directorios necesarios
print_color $YELLOW "📁 Verificando directorios..."
mkdir -p data logs uploads static temp
print_color $GREEN "✅ Directorios verificados"

# Verificar base de datos
if [ ! -f "data/webui.db" ] && [[ "${DATABASE_URL:-}" == *"sqlite"* ]]; then
    print_color $YELLOW "🗄️  Inicializando base de datos SQLite..."
    python -c "
import sys
sys.path.append('.')
try:
    from main import init_db
    init_db()
    print('✅ Base de datos inicializada')
except Exception as e:
    print(f'⚠️  Advertencia: {e}')
"
fi

# Mostrar información de inicio
echo
print_color $CYAN "📋 Información de inicio:"
print_color $BLUE "   🌐 URL: http://${HOST}:${PORT}"
print_color $BLUE "   📚 API Docs: http://${HOST}:${PORT}/docs"
print_color $BLUE "   📖 ReDoc: http://${HOST}:${PORT}/redoc"
print_color $BLUE "   🔧 Workers: ${UVICORN_WORKERS}"
print_color $BLUE "   📊 Log Level: ${LOG_LEVEL}"

# Verificar si el puerto está disponible
if command -v lsof >/dev/null 2>&1; then
    if lsof -Pi :${PORT} -sTCP:LISTEN -t >/dev/null; then
        print_color $RED "⚠️  El puerto ${PORT} ya está en uso"
        print_color $YELLOW "💡 Puedes cambiar el puerto con: export PORT=8081"
        read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

echo
print_color $GREEN "🚀 Iniciando servidor..."
print_color $YELLOW "🛑 Presiona Ctrl+C para detener"
echo

# Función para manejar señales
cleanup() {
    echo
    print_color $YELLOW "🛑 Deteniendo servidor..."
    print_color $GREEN "👋 ¡Hasta luego!"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Determinar comando de Python
PYTHON_CMD="python"
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
fi

# Opciones adicionales para desarrollo
EXTRA_ARGS=""
if [ "${DEVELOPMENT_MODE:-false}" = "true" ]; then
    EXTRA_ARGS="--reload --reload-dir . --reload-exclude '*.pyc' --reload-exclude '__pycache__'"
    print_color $YELLOW "🔧 Modo desarrollo activado (auto-reload)"
fi

# Iniciar aplicación
if [ "${UVICORN_WORKERS}" -gt 1 ]; then
    # Modo producción con múltiples workers
    exec $PYTHON_CMD -m uvicorn main:app \
        --host "${HOST}" \
        --port "${PORT}" \
        --workers "${UVICORN_WORKERS}" \
        --log-level "${LOG_LEVEL,,}" \
        --access-log \
        --forwarded-allow-ips '*'
else
    # Modo desarrollo o single worker
    exec $PYTHON_CMD -m uvicorn main:app \
        --host "${HOST}" \
        --port "${PORT}" \
        --log-level "${LOG_LEVEL,,}" \
        --access-log \
        --forwarded-allow-ips '*' \
        ${EXTRA_ARGS}
fi