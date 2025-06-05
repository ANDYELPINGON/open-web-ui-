#!/bin/bash

# 🚀 Open WebUI - Script de Instalación Automática
# Este script instala y configura Open WebUI automáticamente

set -e  # Salir si hay algún error

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

# Función para imprimir header
print_header() {
    echo ""
    print_color $CYAN "=================================="
    print_color $CYAN "$1"
    print_color $CYAN "=================================="
    echo ""
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para detectar el sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Función para instalar Python en diferentes sistemas
install_python() {
    local os=$(detect_os)
    
    print_color $YELLOW "Instalando Python 3.11+..."
    
    case $os in
        "linux")
            if command_exists apt-get; then
                sudo apt-get update
                sudo apt-get install -y python3.11 python3.11-venv python3.11-pip
            elif command_exists yum; then
                sudo yum install -y python311 python311-pip
            elif command_exists dnf; then
                sudo dnf install -y python3.11 python3.11-pip
            elif command_exists pacman; then
                sudo pacman -S python python-pip
            else
                print_color $RED "No se pudo detectar el gestor de paquetes. Instala Python 3.11+ manualmente."
                exit 1
            fi
            ;;
        "macos")
            if command_exists brew; then
                brew install python@3.11
            else
                print_color $RED "Homebrew no está instalado. Instálalo desde https://brew.sh/"
                exit 1
            fi
            ;;
        "windows")
            print_color $RED "En Windows, descarga Python desde https://python.org/downloads/"
            exit 1
            ;;
        *)
            print_color $RED "Sistema operativo no soportado"
            exit 1
            ;;
    esac
}

# Función para verificar Python
check_python() {
    if command_exists python3; then
        PYTHON_CMD="python3"
    elif command_exists python; then
        PYTHON_CMD="python"
    else
        print_color $RED "Python no está instalado."
        read -p "¿Quieres que lo instale automáticamente? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_python
            check_python
        else
            print_color $RED "Python es requerido. Instálalo manualmente y ejecuta este script de nuevo."
            exit 1
        fi
    fi
    
    # Verificar versión de Python
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
    
    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
        print_color $RED "Se requiere Python 3.11 o superior. Versión actual: $PYTHON_VERSION"
        exit 1
    fi
    
    print_color $GREEN "✓ Python $PYTHON_VERSION detectado"
}

# Función para crear entorno virtual
create_venv() {
    print_color $YELLOW "Creando entorno virtual..."
    
    if [ -d "venv" ]; then
        print_color $YELLOW "El entorno virtual ya existe. ¿Quieres recrearlo?"
        read -p "(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf venv
        else
            print_color $GREEN "✓ Usando entorno virtual existente"
            return
        fi
    fi
    
    $PYTHON_CMD -m venv venv
    print_color $GREEN "✓ Entorno virtual creado"
}

# Función para activar entorno virtual
activate_venv() {
    if [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        source venv/Scripts/activate
    else
        source venv/bin/activate
    fi
    print_color $GREEN "✓ Entorno virtual activado"
}

# Función para instalar dependencias
install_dependencies() {
    print_color $YELLOW "Instalando dependencias..."
    
    # Actualizar pip
    pip install --upgrade pip
    
    # Instalar dependencias principales
    pip install -r requirements.txt
    
    print_color $GREEN "✓ Dependencias instaladas"
}

# Función para crear archivo de configuración
create_config() {
    print_color $YELLOW "Configurando aplicación..."
    
    if [ ! -f ".env" ]; then
        cat > .env << EOF
# Configuración del servidor
PORT=8080
HOST=0.0.0.0
WEBUI_SECRET_KEY=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)

# Base de datos
DATABASE_URL=sqlite:///./data/webui.db

# Configuraciones de la aplicación
ENABLE_SIGNUP=true
DEFAULT_USER_ROLE=user
MAX_UPLOAD_SIZE=100MB

# APIs de IA (opcional - configura según necesites)
# OPENAI_API_KEY=sk-tu-clave-aqui
# ANTHROPIC_API_KEY=tu-clave-aqui
# GOOGLE_API_KEY=tu-clave-aqui

# Configuraciones adicionales
LOG_LEVEL=INFO
ENABLE_COMMUNITY_SHARING=false
EOF
        print_color $GREEN "✓ Archivo .env creado"
    else
        print_color $YELLOW "El archivo .env ya existe, no se sobrescribirá"
    fi
}

# Función para crear directorios necesarios
create_directories() {
    print_color $YELLOW "Creando directorios necesarios..."
    
    mkdir -p data
    mkdir -p logs
    mkdir -p uploads
    mkdir -p static
    
    print_color $GREEN "✓ Directorios creados"
}

# Función para inicializar base de datos
init_database() {
    print_color $YELLOW "Inicializando base de datos..."
    
    # Crear script temporal para inicializar DB
    cat > init_db.py << EOF
import sys
import os
sys.path.append(os.getcwd())

try:
    from main import app
    print("Base de datos inicializada correctamente")
except Exception as e:
    print(f"Error al inicializar base de datos: {e}")
    sys.exit(1)
EOF
    
    python init_db.py
    rm init_db.py
    
    print_color $GREEN "✓ Base de datos inicializada"
}

# Función para crear scripts de inicio mejorados
create_start_scripts() {
    print_color $YELLOW "Creando scripts de inicio..."
    
    # Script para Linux/macOS
    cat > run.sh << 'EOF'
#!/bin/bash

# Activar entorno virtual
if [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Cargar variables de entorno
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Iniciar aplicación
echo "🚀 Iniciando Open WebUI..."
echo "📍 Accede a: http://localhost:${PORT:-8080}"
echo "📚 Documentación API: http://localhost:${PORT:-8080}/docs"
echo ""

python -m uvicorn main:app --host ${HOST:-0.0.0.0} --port ${PORT:-8080} --reload
EOF

    chmod +x run.sh
    
    # Script para Windows
    cat > run.bat << 'EOF'
@echo off
echo 🚀 Iniciando Open WebUI...

REM Activar entorno virtual
call venv\Scripts\activate.bat

REM Cargar variables de entorno
if exist .env (
    for /f "tokens=*" %%i in (.env) do set %%i
)

echo 📍 Accede a: http://localhost:%PORT%
echo 📚 Documentación API: http://localhost:%PORT%/docs
echo.

python -m uvicorn main:app --host %HOST% --port %PORT% --reload
pause
EOF
    
    print_color $GREEN "✓ Scripts de inicio creados (run.sh y run.bat)"
}

# Función para mostrar información final
show_final_info() {
    print_header "🎉 INSTALACIÓN COMPLETADA"
    
    print_color $GREEN "Open WebUI ha sido instalado exitosamente!"
    echo ""
    print_color $CYAN "📋 Próximos pasos:"
    echo ""
    print_color $YELLOW "1. Para iniciar la aplicación:"
    print_color $WHITE "   ./run.sh              (Linux/macOS)"
    print_color $WHITE "   run.bat               (Windows)"
    echo ""
    print_color $YELLOW "2. Accede a la aplicación:"
    print_color $WHITE "   🌐 http://localhost:8080"
    echo ""
    print_color $YELLOW "3. Documentación de la API:"
    print_color $WHITE "   📚 http://localhost:8080/docs"
    echo ""
    print_color $YELLOW "4. Configuración adicional:"
    print_color $WHITE "   📝 Edita el archivo .env para configurar APIs de IA"
    echo ""
    print_color $CYAN "📖 Para más información, consulta el README.md"
    echo ""
    print_color $GREEN "¡Disfruta usando Open WebUI! 🚀"
}

# Función principal
main() {
    print_header "🚀 INSTALADOR DE OPEN WEBUI"
    
    print_color $BLUE "Este script instalará y configurará Open WebUI automáticamente."
    print_color $BLUE "Asegúrate de tener permisos de administrador si es necesario."
    echo ""
    
    read -p "¿Continuar con la instalación? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $YELLOW "Instalación cancelada."
        exit 0
    fi
    
    # Verificar si estamos en el directorio correcto
    if [ ! -f "main.py" ] || [ ! -f "requirements.txt" ]; then
        print_color $RED "Error: No se encontraron los archivos necesarios."
        print_color $RED "Asegúrate de ejecutar este script desde el directorio raíz del proyecto."
        exit 1
    fi
    
    print_header "🔍 VERIFICANDO SISTEMA"
    check_python
    
    print_header "🏗️ CONFIGURANDO ENTORNO"
    create_venv
    activate_venv
    
    print_header "📦 INSTALANDO DEPENDENCIAS"
    install_dependencies
    
    print_header "⚙️ CONFIGURANDO APLICACIÓN"
    create_config
    create_directories
    init_database
    create_start_scripts
    
    show_final_info
}

# Ejecutar función principal
main "$@"