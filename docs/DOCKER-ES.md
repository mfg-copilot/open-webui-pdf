# Guía de Docker para Open WebUI (Español)

## Resumen

**¡Sí, es totalmente posible construir y ejecutar Open WebUI con Docker de forma estándar!** Este proyecto ya viene completamente preparado con toda la configuración necesaria para Docker.

## ¿Qué es Open WebUI?

Open WebUI es una plataforma de IA auto-hospedada, extensible y rica en funciones, diseñada para operar completamente offline. Soporta varios proveedores de LLM como Ollama y APIs compatibles con OpenAI.

## Requisitos Previos

- Docker instalado (versión 20.10 o superior)
- Docker Compose (versión 2.0 o superior, si usas docker-compose)
- 4GB de RAM mínimo recomendado
- 10GB de espacio en disco

## Métodos de Instalación con Docker

### Método 1: Docker Run Simple (Recomendado para Inicio Rápido)

#### Opción A: Si tienes Ollama en tu computadora

```bash
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Opción B: Si Ollama está en otro servidor

```bash
docker run -d -p 3000:8080 \
  -e OLLAMA_BASE_URL=https://tu-servidor-ollama.com \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Opción C: Solo con API de OpenAI

> ⚠️ **Advertencia de Seguridad**: No expongas API keys directamente en la línea de comandos. 
> Para producción, usa `--env-file` o Docker secrets (ver sección de Seguridad más abajo).

```bash
# Método seguro: usando archivo de variables de entorno
echo "OPENAI_API_KEY=tu_clave_secreta" > .env
docker run -d -p 3000:8080 \
  --env-file .env \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main

# O usando Docker secrets (solo para Docker Swarm):
# echo "tu_clave_secreta" | docker secret create openai_key -
# docker service create --secret openai_key ...
```

#### Opción D: Con soporte para GPU NVIDIA

```bash
docker run -d -p 3000:8080 \
  --gpus all \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:cuda
```

### Método 2: Docker Compose (Recomendado para Desarrollo)

El proyecto incluye un `docker-compose.yaml` que facilita la configuración con Ollama integrado.

#### Paso 1: Clonar el repositorio (si aún no lo has hecho)

```bash
git clone https://github.com/mfg-copilot/open-webui-pdf.git
cd open-webui-pdf
```

#### Paso 2: Ejecutar con Docker Compose

```bash
docker compose up -d
```

Este comando:
- Descarga e inicia Ollama en un contenedor
- Construye e inicia Open WebUI en otro contenedor
- Los conecta automáticamente
- Expone el puerto 3000 para acceder a la interfaz web

#### Paso 3: Acceder a la aplicación

Abre tu navegador en: **http://localhost:3000**

### Método 3: Construir desde el Código Fuente

Si deseas construir la imagen Docker localmente desde el código fuente:

#### Construcción básica

```bash
docker build -t open-webui:local .
```

#### Ejecutar la imagen construida localmente

```bash
docker run -d -p 3000:8080 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  open-webui:local
```

#### Construcción con opciones avanzadas

El Dockerfile soporta varios argumentos de construcción (build args):

```bash
# Con soporte CUDA
docker build \
  --build-arg USE_CUDA=true \
  --build-arg USE_CUDA_VER=cu128 \
  -t open-webui:cuda .

# Con Ollama incluido
docker build \
  --build-arg USE_OLLAMA=true \
  -t open-webui:ollama .

# Versión slim (sin modelos pre-descargados)
docker build \
  --build-arg USE_SLIM=true \
  -t open-webui:slim .
```

## Estructura del Proyecto

```
open-webui-pdf/
├── Dockerfile                 # Dockerfile multi-etapa para construcción
├── docker-compose.yaml        # Configuración de Docker Compose
├── .dockerignore             # Archivos a ignorar en Docker
├── backend/                  # Backend Python (FastAPI)
│   ├── requirements.txt      # Dependencias Python
│   └── start.sh             # Script de inicio
├── src/                      # Frontend (Svelte)
├── package.json             # Dependencias Node.js
└── vite.config.ts           # Configuración de Vite
```

## Arquitectura del Dockerfile

El Dockerfile utiliza una **construcción multi-etapa** profesional:

1. **Etapa de Build (Frontend)**:
   - Usa Node.js 22 Alpine
   - Instala dependencias npm
   - Compila el frontend Svelte con Vite

2. **Etapa Base (Backend)**:
   - Usa Python 3.11 Slim
   - Instala dependencias del sistema
   - Instala dependencias Python con uv
   - Pre-descarga modelos de ML (embedding, whisper, etc.)
   - Copia el frontend compilado
   - Configura el backend FastAPI

## Configuración y Variables de Entorno

### Variables Importantes

| Variable | Descripción | Default |
|----------|-------------|---------|
| `OLLAMA_BASE_URL` | URL del servicio Ollama | `/ollama` |
| `OPENAI_API_KEY` | Clave API de OpenAI | - |
| `WEBUI_SECRET_KEY` | Clave secreta para sesiones | - |
| `PORT` | Puerto interno del contenedor | `8080` |
| `ANONYMIZED_TELEMETRY` | Telemetría anónima | `false` |

### Ejemplo de archivo .env

Puedes crear un archivo `.env` para configurar variables de forma segura:

> ⚠️ **Importante**: Genera claves seguras aleatorias, no uses valores predecibles.

```env
OLLAMA_BASE_URL=http://ollama:11434
# Genera una clave segura: openssl rand -base64 32
WEBUI_SECRET_KEY=<genera-una-clave-aleatoria-fuerte>
# Usa tu API key real de OpenAI
OPENAI_API_KEY=sk-<tu-clave-real-de-openai>
```

Y usarlo con docker-compose:

```bash
docker compose --env-file .env up -d
```

**Para Docker Run:**

```bash
docker run -d -p 3000:8080 \
  --env-file .env \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

## Gestión de Volúmenes y Datos

### Persistencia de Datos

El contenedor usa volúmenes para persistir datos:

```bash
# Ver volúmenes creados
docker volume ls | grep open-webui

# Inspeccionar volumen
docker volume inspect open-webui

# Backup del volumen
docker run --rm -v open-webui:/data -v $(pwd):/backup ubuntu tar czf /backup/open-webui-backup.tar.gz /data

# Restaurar backup
docker run --rm -v open-webui:/data -v $(pwd):/backup ubuntu tar xzf /backup/open-webui-backup.tar.gz -C /
```

## Comandos Útiles

### Gestión del Contenedor

```bash
# Ver logs
docker logs -f open-webui

# Detener el contenedor
docker stop open-webui

# Iniciar el contenedor
docker start open-webui

# Reiniciar el contenedor
docker restart open-webui

# Eliminar el contenedor
docker rm -f open-webui

# Entrar al contenedor
docker exec -it open-webui bash
```

### Gestión con Docker Compose

```bash
# Iniciar servicios
docker compose up -d

# Ver logs de todos los servicios
docker compose logs -f

# Ver logs solo de open-webui
docker compose logs -f open-webui

# Detener servicios
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Reconstruir imágenes
docker compose build --no-cache

# Ver estado de servicios
docker compose ps
```

### Actualización de la Imagen

```bash
# Detener y eliminar contenedor actual
docker stop open-webui
docker rm open-webui

# Descargar última versión
docker pull ghcr.io/open-webui/open-webui:main

# Iniciar con la nueva versión
docker run -d -p 3000:8080 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

## Solución de Problemas

### Problema: No puedo conectarme a Ollama

**Solución**: Usa el flag `--network=host`:

```bash
docker run -d --network=host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

Nota: Con `--network=host`, el puerto cambia de 3000 a 8080: **http://localhost:8080**

### Problema: Error de permisos en volúmenes

**Solución**: Verificar permisos del volumen:

```bash
docker exec -it open-webui ls -la /app/backend/data
```

### Problema: La aplicación no inicia

**Solución**: Verificar los logs:

```bash
docker logs open-webui
```

### Problema: Puerto 3000 ya en uso

**Solución**: Cambiar el puerto mapeado:

```bash
docker run -d -p 8080:8080 ...  # Usa puerto 8080 en lugar de 3000
```

## Modo Offline

Para ejecutar en un entorno sin internet:

```bash
docker run -d -p 3000:8080 \
  -e HF_HUB_OFFLINE=1 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

## Seguridad

### Mejores Prácticas

1. **Usa una clave secreta fuerte y aleatoria**:
   ```bash
   # Genera una clave aleatoria segura
   openssl rand -base64 32
   
   # Úsala con Docker Run (a través de archivo .env)
   echo "WEBUI_SECRET_KEY=$(openssl rand -base64 32)" > .env
   docker run -d -p 3000:8080 --env-file .env ...
   ```

2. **NUNCA expongas API keys en la línea de comandos**:
   - ❌ **MAL**: `docker run -e OPENAI_API_KEY=sk-123456...`
   - ✅ **BIEN**: `docker run --env-file .env ...`
   - Las claves en línea de comandos quedan en:
     - Historial del shell (~/.bash_history)
     - Lista de procesos (ps aux)
     - Logs del sistema
     - Output de `docker inspect`

3. **Protege el archivo .env**:
   ```bash
   chmod 600 .env
   echo ".env" >> .gitignore
   ```

4. **No expongas el puerto innecesariamente**: Solo mapea `-p 3000:8080` si necesitas acceso externo

5. **Mantén las imágenes actualizadas**:
   ```bash
   docker pull ghcr.io/open-webui/open-webui:main
   ```

6. **Usa volúmenes nombrados** en lugar de bind mounts para mejor seguridad

7. **Para producción, considera usar Docker Secrets** (en Docker Swarm):
   ```bash
   echo "mi_api_key_secreta" | docker secret create openai_key -
   # Luego referenciar en docker-compose.yaml
   ```

## Recursos Adicionales

- **Documentación Oficial**: https://docs.openwebui.com/
- **Repositorio GitHub**: https://github.com/open-webui/open-webui
- **Discord**: https://discord.gg/5rJgQTnV4s
- **Guía de Troubleshooting**: https://docs.openwebui.com/troubleshooting/

## Conclusión

Este proyecto está **completamente listo para Docker** con:

✅ Dockerfile multi-etapa optimizado  
✅ docker-compose.yaml funcional  
✅ Documentación clara en el README  
✅ Soporte para múltiples arquitecturas  
✅ Variables de entorno bien definidas  
✅ Healthchecks configurados  
✅ Persistencia de datos con volúmenes  

**No se necesitan configuraciones adicionales complejas**. El proyecto sigue las mejores prácticas de Docker y está listo para producción.
