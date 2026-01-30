#!/bin/bash
# Script de Inicio Rápido para Open WebUI con Docker
# Este script facilita el inicio de Open WebUI usando Docker

# Note: Using || true for cleanup commands that may fail if containers don't exist
# This is intentional for the cleanup section only

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         Open WebUI - Inicio Rápido con Docker            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado."
    echo "   Por favor, instala Docker desde: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✓ Docker está instalado: $(docker --version)"
echo ""

# Menú de opciones
echo "Selecciona el método de inicio:"
echo ""
echo "1) Docker Compose (con Ollama incluido) - Recomendado"
echo "2) Docker Run (imagen pre-construida de GitHub)"
echo "3) Construir desde código fuente local"
echo "4) Detener y eliminar contenedores"
echo ""
read -p "Opción [1-4]: " option

case $option in
    1)
        echo ""
        echo "🚀 Iniciando con Docker Compose..."
        echo ""
        
        # Verificar si docker compose está disponible
        if ! docker compose version &> /dev/null; then
            echo "❌ Error: Docker Compose no está disponible."
            echo "   Instala Docker Compose o usa la opción 2."
            exit 1
        fi
        
        # Iniciar con docker compose
        if ! docker compose up -d; then
            echo "❌ Error al iniciar con Docker Compose"
            exit 1
        fi
        
        echo ""
        echo "✅ Servicios iniciados:"
        docker compose ps
        echo ""
        echo "🌐 Open WebUI está disponible en: http://localhost:3000"
        echo "📊 Para ver logs: docker compose logs -f"
        echo "🛑 Para detener: docker compose down"
        ;;
        
    2)
        echo ""
        echo "🚀 Iniciando con Docker Run (imagen de GitHub)..."
        echo ""
        
        # Preguntar por configuración de Ollama
        echo "¿Dónde está tu servidor Ollama?"
        echo "1) En esta misma computadora (localhost)"
        echo "2) En otro servidor"
        echo "3) No uso Ollama (solo OpenAI API)"
        echo ""
        read -p "Opción [1-3]: " ollama_option
        
        case $ollama_option in
            1)
                echo "Iniciando Open WebUI conectado a Ollama local..."
                docker run -d -p 3000:8080 \
                    --add-host=host.docker.internal:host-gateway \
                    -v open-webui:/app/backend/data \
                    --name open-webui \
                    --restart always \
                    ghcr.io/open-webui/open-webui:main
                ;;
            2)
                read -p "URL del servidor Ollama (ej: http://192.168.1.100:11434): " ollama_url
                # Validar que la URL no esté vacía y tenga formato básico de URL
                if [[ -z "$ollama_url" ]] || [[ ! "$ollama_url" =~ ^https?:// ]]; then
                    echo "❌ Error: URL inválida. Debe comenzar con http:// o https://"
                    exit 1
                fi
                docker run -d -p 3000:8080 \
                    -e "OLLAMA_BASE_URL=$ollama_url" \
                    -v open-webui:/app/backend/data \
                    --name open-webui \
                    --restart always \
                    ghcr.io/open-webui/open-webui:main
                ;;
            3)
                echo ""
                echo "⚠️  ADVERTENCIA DE SEGURIDAD:"
                echo "   Las API keys no deben ingresarse directamente por seguridad."
                echo "   Recomendamos usar un archivo .env en su lugar."
                echo ""
                read -p "¿Continuar de todos modos? (s/n): " continue_unsafe
                if [[ "$continue_unsafe" != "s" && "$continue_unsafe" != "S" ]]; then
                    echo "Operación cancelada. Usa un archivo .env:"
                    echo "  1. Crea .env con: echo 'OPENAI_API_KEY=tu-key' > .env"
                    echo "  2. Ejecuta: docker run -d -p 3000:8080 --env-file .env -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main"
                    exit 0
                fi
                
                read -s -p "API Key de OpenAI: " openai_key
                echo ""
                # Validar que la clave no esté vacía
                if [[ -z "$openai_key" ]]; then
                    echo "❌ Error: La API key no puede estar vacía"
                    exit 1
                fi
                docker run -d -p 3000:8080 \
                    -e "OPENAI_API_KEY=$openai_key" \
                    -v open-webui:/app/backend/data \
                    --name open-webui \
                    --restart always \
                    ghcr.io/open-webui/open-webui:main
                ;;
            *)
                echo "Opción inválida"
                exit 1
                ;;
        esac
        
        echo ""
        echo "✅ Open WebUI iniciado correctamente"
        echo "🌐 Accede en: http://localhost:3000"
        echo "📊 Ver logs: docker logs -f open-webui"
        echo "🛑 Detener: docker stop open-webui"
        ;;
        
    3)
        echo ""
        echo "🔨 Construyendo desde código fuente..."
        echo ""
        
        # Construir la imagen
        if ! docker build -t open-webui:local .; then
            echo "❌ Error al construir la imagen"
            exit 1
        fi
        
        echo ""
        echo "✅ Imagen construida exitosamente"
        echo ""
        echo "¿Deseas iniciar el contenedor ahora? (s/n)"
        read -p "Respuesta: " start_now
        
        if [[ "$start_now" == "s" || "$start_now" == "S" ]]; then
            docker run -d -p 3000:8080 \
                --add-host=host.docker.internal:host-gateway \
                -v open-webui:/app/backend/data \
                --name open-webui \
                --restart always \
                open-webui:local
            
            echo ""
            echo "✅ Open WebUI iniciado correctamente"
            echo "🌐 Accede en: http://localhost:3000"
        fi
        ;;
        
    4)
        echo ""
        echo "🛑 Deteniendo y eliminando contenedores..."
        echo ""
        
        # Detener docker compose si existe
        if [ -f "docker-compose.yaml" ]; then
            docker compose down 2>/dev/null || true
        fi
        
        # Detener y eliminar contenedor standalone
        docker stop open-webui 2>/dev/null || true
        docker rm open-webui 2>/dev/null || true
        
        echo "✅ Contenedores detenidos y eliminados"
        echo ""
        echo "Nota: Los datos persisten en el volumen 'open-webui'"
        echo "Para eliminar también los datos: docker volume rm open-webui"
        ;;
        
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Para más información, consulta: docs/DOCKER-ES.md"
echo "═══════════════════════════════════════════════════════════"
