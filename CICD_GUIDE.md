# CI/CD Guide — Sistema Blitz

Guia para configurar el pipeline de despliegue automatico desde GitHub hacia el VPS de IONOS.

**Fase actual: 1 — Solo Backend + DB. Frontend desactivado.**

---

## Arquitectura del pipeline

```
push a main        GitHub Actions          GHCR                  VPS IONOS
-----------     ------------------     -------------     -------------------------
Backend repo  →  Build + Push imagen  →  ghcr.io/...  ←  docker compose pull + up
Infra repo    →  (manual: solo contiene compose.yaml y esta guia)
```

El repo del backend tiene un workflow (`.github/workflows/deploy.yml`) que:
1. Construye la imagen Docker.
2. La publica en **GitHub Container Registry (GHCR)**.
3. Se conecta al VPS via SSH y ejecuta `docker compose pull backend && up -d backend db`.

---

## 1. Secrets que debes configurar

Configura estos secrets en el repo **Blitz-backend**:

**github.com/jesuslab135/Blitz-backend > Settings > Secrets and variables > Actions > New repository secret**

| Secret | Valor | Ejemplo |
|---|---|---|
| `VPS_HOST` | IP publica del servidor IONOS | `85.215.xxx.xxx` |
| `VPS_USER` | Usuario SSH del servidor | `root` |
| `VPS_SSH_KEY` | Contenido completo de la clave privada SSH | Empieza con `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `VPS_DEPLOY_PATH` | Ruta absoluta donde esta `compose.yaml` en el VPS | `/opt/blitz` |

> `GITHUB_TOKEN` lo provee GitHub automaticamente. **No necesitas crearlo.**

### Generar la clave SSH (si no la tienes)

```bash
# En tu maquina local:
ssh-keygen -t ed25519 -C "github-actions-blitz" -f ~/.ssh/blitz_deploy

# Copiar la clave PUBLICA al VPS:
ssh-copy-id -i ~/.ssh/blitz_deploy.pub root@TU_IP_VPS

# El contenido de ~/.ssh/blitz_deploy (la PRIVADA) es lo que pegas en el secret VPS_SSH_KEY
cat ~/.ssh/blitz_deploy
```

---

## 2. Permisos de GHCR (GITHUB_TOKEN)

El workflow ya incluye el bloque `permissions` necesario:

```yaml
permissions:
  contents: read
  packages: write
```

Esto permite que el `GITHUB_TOKEN` automatico de GitHub Actions publique imagenes en GHCR. **No necesitas crear un PAT para el build.**

### Activar permisos del workflow (primera vez)

Si el push falla con `403 Forbidden` al publicar la imagen:

1. Ve al repo en GitHub > **Settings > Actions > General**.
2. Baja hasta **Workflow permissions**.
3. Selecciona **Read and write permissions**.
4. Guarda.

---

## 3. Permisos cruzados (repos de diferentes usuarios)

El backend pertenece a `jesuslab135` y el frontend a `FaexAS31`. Las imagenes GHCR quedan bajo namespaces distintos:

- `ghcr.io/jesuslab135/blitz-backend`
- `ghcr.io/faexas31/blitz-frontend` (futuro, Fase 2)

El VPS necesita poder hacer `docker pull` de esas imagenes. Opciones:

### Opcion A — Imagen publica (recomendada para Fase 1)

Despues del primer push exitoso del workflow, la imagen aparece en GHCR como **privada** por defecto. Cambiala a publica:

1. Ve a `github.com/jesuslab135` > tab **Packages** > click en `blitz-backend`.
2. **Package settings** > **Danger zone** > **Change visibility** > **Public**.

Con imagen publica, el VPS no necesita `docker login` para hacer pull.

### Opcion B — Imagen privada + PAT

Si necesitas que la imagen sea privada:

1. `jesuslab135` crea un **Personal Access Token (classic)** con scope `read:packages`.
   - GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic).
2. En el VPS, loguea Docker:

```bash
echo "TU_PAT_AQUI" | docker login ghcr.io -u jesuslab135 --password-stdin
```

Docker guarda las credenciales en `~/.docker/config.json` y las usa automaticamente en cada pull.

### Opcion C — Organizacion GitHub (la mas limpia a largo plazo)

Crear una organizacion (ej. `BlitzApp`) y mover los repos ahi. Asi todas las imagenes quedan bajo `ghcr.io/blitzapp/*` y un solo PAT de la organizacion da acceso a todo.

---

## 4. Preparacion del VPS (primera vez)

Ejecuta estos comandos conectado al VPS via SSH:

### 4.1 — Instalar Docker

```bash
curl -fsSL https://get.docker.com | sh

# Verificar instalacion
docker --version
docker compose version
```

### 4.2 — Crear directorio de despliegue

```bash
mkdir -p /opt/blitz
cd /opt/blitz
```

### 4.3 — Obtener compose.yaml

Opcion A — clonar el repo de infra:
```bash
git clone https://github.com/FaexAS31/Blitz-infra.git .
```

Opcion B — copiar solo el archivo desde tu maquina local:
```bash
# Desde tu maquina local:
scp compose.yaml root@TU_IP_VPS:/opt/blitz/
```

### 4.4 — Activar toggles de PRODUCCION en compose.yaml

Dentro del VPS, edita `compose.yaml` y haz estos cambios:

```bash
nano /opt/blitz/compose.yaml
```

Para el servicio **backend**:
- **Comentar**: `build:`, `env_file:`, `volumes:` (el bloque que monta `../backend/src`)
- **Descomentar**: `image: ghcr.io/jesuslab135/blitz-backend:latest`, `environment:` con las variables `${}`

Para el servicio **db**:
- **Comentar**: el bloque `environment:` con valores hardcodeados
- **Descomentar**: el bloque `environment:` con variables `${}`

El servicio **frontend** ya esta comentado al 100%.

### 4.5 — Crear archivo .env con variables de produccion

```bash
cat > /opt/blitz/.env << 'EOF'
DB_USER=blitz_db
DB_PASSWORD=UnaPasswordMuySegura!
DB_NAME=blitz_database
SECRET_KEY=una-clave-secreta-larga-y-aleatoria-para-produccion
PGADMIN_EMAIL=admin@tudominio.com
PGADMIN_PASSWORD=OtraPasswordSegura456!
EOF
```

> Cambia las passwords por valores reales y seguros.

### 4.6 — (Solo si usas imagenes privadas — Opcion B)

```bash
echo "TU_PAT" | docker login ghcr.io -u jesuslab135 --password-stdin
```

### 4.7 — Primer despliegue manual

```bash
cd /opt/blitz
docker compose pull backend
docker compose up -d backend db
```

### 4.8 — Verificar que funciona

```bash
# Ver contenedores corriendo
docker compose ps

# Debe mostrar blitz_backend y blitz_db como "Up"

# Probar que el backend responde
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/schema/swagger-ui/

# Debe devolver 200
```

---

## 5. Resumen de archivos por repo

| Repo | Archivo | Funcion |
|---|---|---|
| **Blitz-backend** | `.github/workflows/deploy.yml` | Build imagen + push GHCR + deploy SSH |
| **Blitz-infra** | `compose.yaml` | Orquestacion de servicios con toggles LOCAL/PROD |
| **Blitz-infra** | `CICD_GUIDE.md` | Esta guia |
| **Blitz-infra** | `.env` (solo en VPS, nunca en el repo) | Variables de produccion |

---

## 6. Checklist pre-despliegue

### GitHub (repo Blitz-backend)

- [ ] Secret `VPS_HOST` configurado
- [ ] Secret `VPS_USER` configurado
- [ ] Secret `VPS_SSH_KEY` configurado (clave privada completa)
- [ ] Secret `VPS_DEPLOY_PATH` configurado (ej. `/opt/blitz`)
- [ ] Workflow permissions en "Read and write" (Settings > Actions > General)

### VPS IONOS

- [ ] Docker y Docker Compose instalados
- [ ] Directorio `/opt/blitz` creado
- [ ] `compose.yaml` presente con toggles de PRODUCCION activos
- [ ] Archivo `.env` creado con credenciales reales
- [ ] Clave publica SSH de GitHub Actions aceptada (`~/.ssh/authorized_keys`)
- [ ] Imagen GHCR publica (Opcion A) o `docker login` configurado (Opcion B)

### Validacion

- [ ] `docker compose ps` muestra `blitz_backend` y `blitz_db` como "Up"
- [ ] `curl http://localhost:8000/api/schema/swagger-ui/` devuelve 200

---

## 7. Flujo diario de trabajo

```
1. Desarrollas en local con los toggles de LOCAL activos
2. git push a main en el repo Blitz-backend
3. GitHub Actions construye la imagen y la publica en GHCR
4. GitHub Actions se conecta al VPS via SSH
5. El VPS ejecuta: docker compose pull backend && docker compose up -d backend db
6. Limpia imagenes viejas automaticamente
7. Listo — el VPS ya corre la nueva version
```

Tambien puedes disparar el deploy manualmente desde:
**github.com/jesuslab135/Blitz-backend > Actions > Build & Deploy Backend > Run workflow**

Si algo falla, revisa el tab **Actions** en GitHub para ver los logs del workflow.

---

## Fase 2 — Cuando el frontend este listo

1. Crear workflow `.github/workflows/deploy.yml` en el repo `Blitz-frontend` (copia del backend, cambiando `IMAGE_NAME` a `ghcr.io/faexas31/blitz-frontend` y el servicio en el deploy a `frontend`).
2. Descomentar el servicio `frontend` en `compose.yaml`.
3. Configurar los mismos 4 secrets en el repo `Blitz-frontend`.
4. Hacer la imagen de frontend publica en GHCR (o agregar otro `docker login` en el VPS).
5. Push a main en el repo frontend para disparar el primer deploy.
