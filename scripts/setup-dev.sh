#!/bin/bash

# 🛠️ Script de Configuración para Desarrollo - Open WebUI

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo ""
    print_color $BLUE "=================================="
    print_color $BLUE "$1"
    print_color $BLUE "=================================="
    echo ""
}

print_header "🛠️ CONFIGURACIÓN DE DESARROLLO"

# Verificar que estamos en el directorio correcto
if [ ! -f "main.py" ]; then
    print_color $RED "Error: Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    print_color $YELLOW "Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
print_color $YELLOW "Activando entorno virtual..."
source venv/bin/activate

# Actualizar pip
print_color $YELLOW "Actualizando pip..."
pip install --upgrade pip

# Instalar dependencias de desarrollo
print_color $YELLOW "Instalando dependencias de desarrollo..."
cat > requirements-dev.txt << EOF
# Dependencias de desarrollo
black==25.1.0
flake8==7.1.1
isort==5.13.2
mypy==1.13.0
pytest==8.3.5
pytest-asyncio==0.24.0
pytest-cov==6.0.0
pytest-mock==3.14.0
pre-commit==4.0.1
mkdocs==1.6.1
mkdocs-material==9.5.44
mkdocs-mermaid2-plugin==1.1.1

# Herramientas de testing
httpx==0.28.1
factory-boy==3.3.1
faker==33.1.0

# Herramientas de debugging
ipdb==0.13.13
rich==13.9.4
typer==0.15.1
EOF

pip install -r requirements.txt
pip install -r requirements-dev.txt

# Configurar pre-commit
print_color $YELLOW "Configurando pre-commit hooks..."
cat > .pre-commit-config.yaml << EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 25.1.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 7.1.1
    hooks:
      - id: flake8
        args: [--max-line-length=88, --extend-ignore=E203]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]
EOF

pre-commit install

# Crear configuración de desarrollo
print_color $YELLOW "Creando configuración de desarrollo..."
cat > .env.dev << EOF
# Configuración de desarrollo
DEBUG=true
LOG_LEVEL=DEBUG
RELOAD=true
PORT=8080
HOST=0.0.0.0

# Base de datos de desarrollo
DATABASE_URL=sqlite:///./data/webui_dev.db

# Seguridad relajada para desarrollo
WEBUI_SECRET_KEY=dev-secret-key-not-for-production
ENABLE_SIGNUP=true
ENABLE_CORS=true
CORS_ALLOW_ORIGIN=*

# APIs de prueba (configura con tus claves reales)
# OPENAI_API_KEY=sk-test-key
# ANTHROPIC_API_KEY=test-key
# GOOGLE_API_KEY=test-key

# Configuraciones de desarrollo
ENABLE_LOGGING=true
LOG_FILE=./logs/webui_dev.log
UPLOAD_DIR=./uploads_dev
MAX_UPLOAD_SIZE=50MB
EOF

# Crear directorios de desarrollo
print_color $YELLOW "Creando directorios de desarrollo..."
mkdir -p data logs uploads_dev static tests docs

# Crear configuración de pytest
print_color $YELLOW "Configurando pytest..."
cat > pytest.ini << EOF
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --tb=short
    --strict-markers
    --disable-warnings
    --cov=.
    --cov-report=term-missing
    --cov-report=html:htmlcov
    --cov-fail-under=80

markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
EOF

# Crear configuración de mypy
print_color $YELLOW "Configurando mypy..."
cat > mypy.ini << EOF
[mypy]
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True

[mypy-tests.*]
disallow_untyped_defs = False
EOF

# Crear estructura de tests básica
print_color $YELLOW "Creando estructura de tests..."
cat > tests/__init__.py << EOF
"""Tests para Open WebUI"""
EOF

cat > tests/conftest.py << EOF
"""Configuración de pytest para Open WebUI"""
import pytest
import asyncio
from fastapi.testclient import TestClient
from main import app

@pytest.fixture
def client():
    """Cliente de pruebas FastAPI"""
    return TestClient(app)

@pytest.fixture
def event_loop():
    """Event loop para tests async"""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()
EOF

cat > tests/test_main.py << EOF
"""Tests básicos para la aplicación principal"""
import pytest
from fastapi.testclient import TestClient

def test_health_endpoint(client: TestClient):
    """Test del endpoint de salud"""
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()

def test_root_endpoint(client: TestClient):
    """Test del endpoint raíz"""
    response = client.get("/")
    assert response.status_code == 200

def test_docs_endpoint(client: TestClient):
    """Test del endpoint de documentación"""
    response = client.get("/docs")
    assert response.status_code == 200
EOF

# Crear Makefile para comandos comunes
print_color $YELLOW "Creando Makefile..."
cat > Makefile << EOF
.PHONY: help install dev test lint format clean run docs

help: ## Mostrar esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' \$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", \$\$1, \$\$2}'

install: ## Instalar dependencias
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

dev: ## Configurar entorno de desarrollo
	./scripts/setup-dev.sh

test: ## Ejecutar tests
	pytest

test-cov: ## Ejecutar tests con cobertura
	pytest --cov=. --cov-report=html --cov-report=term

lint: ## Verificar código con linters
	flake8 .
	mypy .
	black --check .
	isort --check-only .

format: ## Formatear código
	black .
	isort .

clean: ## Limpiar archivos temporales
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info

run: ## Ejecutar aplicación en modo desarrollo
	export \$\$(cat .env.dev | xargs) && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

run-prod: ## Ejecutar aplicación en modo producción
	export \$\$(cat .env | xargs) && python -m uvicorn main:app --host 0.0.0.0 --port 8080

docs: ## Generar documentación
	mkdocs serve

build-docs: ## Construir documentación
	mkdocs build

docker-build: ## Construir imagen Docker
	docker build -t open-webui .

docker-run: ## Ejecutar con Docker
	docker run -p 8080:8080 open-webui

docker-dev: ## Ejecutar con Docker en modo desarrollo
	docker-compose -f docker-compose.dev.yml up

pre-commit: ## Ejecutar pre-commit en todos los archivos
	pre-commit run --all-files
EOF

# Crear configuración de MkDocs para documentación
print_color $YELLOW "Configurando documentación..."
cat > mkdocs.yml << EOF
site_name: Open WebUI
site_description: Interfaz Web Avanzada para IA
site_author: ANDYELPINGON
site_url: https://github.com/ANDYELPINGON/open-web-ui-

repo_name: ANDYELPINGON/open-web-ui-
repo_url: https://github.com/ANDYELPINGON/open-web-ui-

theme:
  name: material
  palette:
    - scheme: default
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy

markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences
  - pymdownx.mermaid2
  - admonition
  - codehilite
  - toc:
      permalink: true

nav:
  - Inicio: index.md
  - Instalación: installation.md
  - Configuración: configuration.md
  - API: api.md
  - Desarrollo: development.md
  - Despliegue: deployment.md

plugins:
  - search
  - mermaid2
EOF

# Crear script de desarrollo rápido
print_color $YELLOW "Creando script de desarrollo rápido..."
cat > dev.py << 'EOF'
#!/usr/bin/env python3
"""
Script de desarrollo rápido para Open WebUI
Uso: python dev.py [comando]
"""
import os
import sys
import subprocess
import typer
from rich.console import Console
from rich.table import Table

app = typer.Typer()
console = Console()

@app.command()
def run():
    """Ejecutar aplicación en modo desarrollo"""
    console.print("🚀 Iniciando Open WebUI en modo desarrollo...", style="green")
    os.system("export $(cat .env.dev | xargs) && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080")

@app.command()
def test():
    """Ejecutar tests"""
    console.print("🧪 Ejecutando tests...", style="blue")
    os.system("pytest -v")

@app.command()
def lint():
    """Verificar código"""
    console.print("🔍 Verificando código...", style="yellow")
    os.system("flake8 . && mypy . && black --check . && isort --check-only .")

@app.command()
def format():
    """Formatear código"""
    console.print("✨ Formateando código...", style="magenta")
    os.system("black . && isort .")

@app.command()
def clean():
    """Limpiar archivos temporales"""
    console.print("🧹 Limpiando archivos temporales...", style="red")
    os.system("find . -type f -name '*.pyc' -delete")
    os.system("find . -type d -name '__pycache__' -delete")
    os.system("rm -rf .pytest_cache htmlcov .coverage")

@app.command()
def status():
    """Mostrar estado del proyecto"""
    table = Table(title="Estado del Proyecto Open WebUI")
    table.add_column("Componente", style="cyan")
    table.add_column("Estado", style="green")
    
    # Verificar entorno virtual
    venv_status = "✅ Activo" if os.environ.get('VIRTUAL_ENV') else "❌ Inactivo"
    table.add_row("Entorno Virtual", venv_status)
    
    # Verificar archivos importantes
    files_to_check = ['.env.dev', 'requirements.txt', 'main.py']
    for file in files_to_check:
        status = "✅ Existe" if os.path.exists(file) else "❌ Faltante"
        table.add_row(f"Archivo {file}", status)
    
    console.print(table)

if __name__ == "__main__":
    app()
EOF

chmod +x dev.py

print_color $GREEN "✅ Configuración de desarrollo completada!"
echo ""
print_color $BLUE "📋 Comandos disponibles:"
print_color $YELLOW "  make run          - Ejecutar en modo desarrollo"
print_color $YELLOW "  make test         - Ejecutar tests"
print_color $YELLOW "  make lint         - Verificar código"
print_color $YELLOW "  make format       - Formatear código"
print_color $YELLOW "  make docs         - Servir documentación"
print_color $YELLOW "  python dev.py run - Script de desarrollo rápido"
echo ""
print_color $GREEN "🎉 ¡Entorno de desarrollo listo!"