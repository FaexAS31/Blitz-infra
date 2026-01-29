

```markdown
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

```

Tu estructura debe verse así:

```text
BlitzSystem/
├── backend/
├── frontend/
└── infra/      <-- Aquí vive el docker compose

```

---

##  2. Configuración de Variables de Entorno

Antes de encender Docker, el Backend necesita sus credenciales.

1. Ve a la carpeta `backend/src/`.
2. Crea un archivo llamado `.env`.
3. Pega el siguiente contenido (Asegúrate de que `HOST` sea `db`):

```ini
# Archivo: backend/src/.env

DB_USER='blitz_db'
DB_PASSWORD='Blitz@$135'
DB_NAME='blitz_database'
SECRET_KEY='django-insecure-tu-clave-secreta-aqui'
# IMPORTANTE: En Docker, el host no es localhost, es el nombre del servicio
HOST='db'
PORT='5432'

```

---

##  3. Encender la Infraestructura

1. Ve a la carpeta de infraestructura:
```bash
cd infra

```


2. Levanta los contenedores en segundo plano:
```bash
docker compose up -d

```
si les da error poner en el Dockerfile (frontend y backend):
RUN apt-get update && apt-get install -y bash
COPY scripts/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh && bash /tmp/install.sh

lo de mas lo dejas igual

3. Verifica que los 4 contenedores (backend, frontend, db, pgadmin) estén corriendo:
```bash
docker compose ps

```



---

##  4. Configuración del Backend (Setup Inicial)

El contenedor de Ubuntu viene "limpio". Necesitamos instalar las librerías de sistema para compilar dependencias y luego las librerías de Python.

**1. Entrar a la terminal del Backend:**

```bash
docker exec -it ubuntu_backend bash

```

**2. Instalar dependencias del Sistema Operativo (CRÍTICO):**
Ejecuta este bloque dentro del contenedor para permitir la compilación de `dbus-python` y `psycopg2`.

```bash
apt-get update
apt-get install -y pkg-config libdbus-1-dev libglib2.0-dev gcc python3-dev

```

**3. Instalar requerimientos de Python:**
Ahora que el sistema tiene las herramientas de compilación, instalamos Django y DRF.

```bash
cd /app
pip install -r requirements.txt

```

**4. Migraciones y Superusuario:**

```bash
# Crear tablas en la BD
python3 manage.py migrate

# Crear usuario administrador (sigue las instrucciones en pantalla)
python3 manage.py createsuperuser

```

**5. Encender el Servidor Django:**
 **IMPORTANTE:** Debes usar `0.0.0.0` para exponer el servidor fuera del contenedor. Si usas localhost, Windows no podrá acceder.

```bash
python3 manage.py runserver 0.0.0.0:8000

```

*(Mantén esta terminal abierta o usa `Ctrl+Z` y `bg` para dejarlo en segundo plano, aunque lo ideal es dejar una terminal dedicada a los logs).*

---

##  5. Configuración del Frontend

1. Abre una **nueva terminal** (en tu PC, no dentro del backend).
2. Entra al contenedor del frontend:
```bash
docker exec -it ubuntu_frontend bash

```


3. Instalar dependencias de Node:
```bash
cd /app
npm install

```


4. Correr servidor de desarrollo:
```bash
npm run dev -- --host

```



---

##  6. Accesos

Una vez todo esté corriendo:

* **Backend API:** [http://localhost:8000](https://www.google.com/search?q=http://localhost:8000)
* **Backend Admin:** [http://localhost:8000/admin](https://www.google.com/search?q=http://localhost:8000/admin)
* **Frontend (React):** [http://localhost:5173](https://www.google.com/search?q=http://localhost:5173)
* **pgAdmin (Gestión BD):** [http://localhost:6060](https://www.google.com/search?q=http://localhost:6060)
* *User:* jefeing.esteban@gmail.com
* *Pass:* Blitz@$135
* *Host Name para conectar server:* `db`



---

##  Solución de Problemas Comunes

* **Error "Connection Refused" en Django:**
* ¿Estás corriendo con `0.0.0.0:8000`?
* ¿Pusiste `HOST='db'` en el `.env`?


* **Error "pkg-config not found" al hacer pip install:**
* Se te olvidó correr el paso 4.2 (`apt-get install ...`).


* **Contenedores se apagan solos:**
* Asegúrate de que `tty: true` esté en el `compose.yaml`. Reinicia con `docker compose up -d`.



```

```
