# Open WebUI - Guía Rápida en Español 🇪🇸

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-Open_WebUI-green)](./LICENSE)

## ¿Qué es esto?

**Open WebUI** es una plataforma de inteligencia artificial auto-hospedada, extensible y fácil de usar. Funciona completamente offline y soporta múltiples proveedores de LLM como Ollama y APIs compatibles con OpenAI.

## ⚡ Inicio Rápido con Docker

### Método 1: Script Automático (Más Fácil)

```bash
chmod +x docker-start.sh
./docker-start.sh
```

El script te guiará paso a paso para elegir la mejor configuración para ti.

### Método 2: Docker Compose (Recomendado)

```bash
docker compose up -d
```

Luego abre tu navegador en: **http://localhost:3000**

### Método 3: Docker Run Simple

```bash
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

## 📚 Documentación Completa

Para una guía detallada en español sobre Docker, consulta:

👉 **[docs/DOCKER-ES.md](./docs/DOCKER-ES.md)** 👈

Esta guía incluye:

- ✅ Múltiples métodos de instalación
- ✅ Configuración avanzada
- ✅ Variables de entorno
- ✅ Solución de problemas comunes
- ✅ Comandos útiles
- ✅ Gestión de datos y backups
- ✅ Mejores prácticas de seguridad

## 🚀 Características Principales

- 🛠️ **Configuración Sencilla**: Instalación fácil con Docker
- 🤖 **Integración con Ollama/OpenAI**: Soporte para múltiples proveedores
- 📱 **Diseño Responsivo**: Funciona en escritorio y móvil
- 🌐 **Multilingüe**: Soporte para múltiples idiomas
- 📚 **RAG (Retrieval Augmented Generation)**: Integración con documentos
- 🎨 **Generación de Imágenes**: Soporte para DALL-E y otros
- 🔐 **Control de Acceso**: RBAC y autenticación empresarial

## 📋 Requisitos

- Docker 20.10+ 
- Docker Compose 2.0+ (opcional, para usar docker-compose)
- 4GB RAM mínimo
- 10GB espacio en disco

## 🐳 ¿Es posible usar Docker?

**¡SÍ, completamente!** Este proyecto está 100% listo para Docker:

✅ Incluye `Dockerfile` multi-etapa optimizado  
✅ Incluye `docker-compose.yaml` funcional  
✅ Sigue las mejores prácticas de Docker  
✅ Listo para producción  
✅ **No necesitas configuraciones complejas**

El proyecto usa una arquitectura moderna:
- **Frontend**: Svelte + Vite (Node.js 22)
- **Backend**: Python 3.11 + FastAPI
- **Base de datos**: SQLite (con opciones PostgreSQL)
- **Modelos ML**: Sentence Transformers, Whisper, etc.

## 🔧 Comandos Útiles

```bash
# Ver logs
docker logs -f open-webui

# Detener
docker stop open-webui

# Reiniciar
docker restart open-webui

# Ver estado (con compose)
docker compose ps

# Ver logs (con compose)
docker compose logs -f
```

## 🆘 Solución de Problemas

### No puedo conectarme a Ollama

Usa `--network=host`:

```bash
docker run -d --network=host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

Accede en: **http://localhost:8080** (nota el cambio de puerto)

### Más problemas?

Consulta la [Guía Completa de Docker](./docs/DOCKER-ES.md) o el [README original en inglés](./README.md).

## 📖 Documentación Adicional

- 📘 [README Original (English)](./README.md) - Documentación completa del proyecto
- 🐳 [Guía de Docker en Español](./docs/DOCKER-ES.md) - Guía detallada de Docker
- 🔧 [Troubleshooting](./TROUBLESHOOTING.md) - Solución de problemas
- 🌐 [Documentación Oficial](https://docs.openwebui.com/) - Docs online completas

## 🤝 Comunidad y Soporte

- 💬 [Discord](https://discord.gg/5rJgQTnV4s) - Chat de la comunidad
- 🐛 [Issues](https://github.com/open-webui/open-webui/issues) - Reportar bugs
- 🌟 [GitHub](https://github.com/open-webui/open-webui) - Repositorio principal

## 📝 Licencia

Este proyecto está bajo la licencia Open WebUI. Ver [LICENSE](./LICENSE) para más detalles.

---

**¿Preguntas?** Consulta la documentación completa o únete a nuestra comunidad en Discord.
