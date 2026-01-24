#  Guía de Despliegue Local - Sistema Blitz

Esta guía detalla los pasos exactos para clonar, configurar y levantar el entorno de desarrollo del Sistema Blitz (Backend, Frontend e Infraestructura) utilizando Docker.

##  1. Preparación del Espacio de Trabajo

Para que Docker encuentre correctamente los archivos, es **CRÍTICO** respetar la estructura de carpetas.

1. Crea una carpeta principal (ej. `BlitzSystem`).
2. Abre una terminal en esa carpeta.
3. Clona los 3 repositorios **respetando los nombres de carpeta** (`backend`, `frontend`, `infra`).

```bash
# Estando dentro de BlitzSystem/

# 1. Backend
git clone [https://github.com/jesuslab135/Blitz-backend.git](https://github.com/jesuslab135/Blitz-backend.git) backend

# 2. Frontend
git clone [https://github.com/FaexAS31/Blitz-frontend.git](https://github.com/FaexAS31/Blitz-frontend.git) frontend

# 3. Infraestructura
git clone [https://github.com/FaexAS31/Blitz-infra.git](https://github.com/FaexAS31/Blitz-infra.git) infra
