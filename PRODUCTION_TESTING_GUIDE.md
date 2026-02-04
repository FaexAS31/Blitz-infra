# Guia de Pruebas en Produccion — SquadUp Backend API

Guia paso a paso para acceder al servidor de produccion, obtener un token de autenticacion y probar los endpoints de la API desde Swagger UI.

---

## Requisitos previos

- Una terminal (CMD, PowerShell, o cualquier cliente SSH)
- Un navegador web
- Credenciales de acceso al servidor (IP y contrasena)

---

## Paso 1 — Abrir Swagger UI en el navegador

Abre tu navegador y ve a:

```
http://198.71.54.171:8000/api/schema/swagger-ui/
```

Veras la documentacion interactiva de la API con todos los endpoints disponibles.

> **Nota:** Todos los endpoints (excepto Swagger) requieren autenticacion. En el siguiente paso obtendremos el token necesario.

---

## Paso 2 — Conectarse al servidor por SSH

Abre una terminal y ejecuta:

```bash
ssh root@198.71.54.171
```

Cuando pida la contrasena, ingresala (no se mostraran caracteres mientras escribes, eso es normal).

Una vez conectado, veras algo como:

```
Welcome to Ubuntu 24.04.3 LTS
root@ubuntu:~#
```

---

## Paso 3 — Entrar al contenedor del backend

Ejecuta el siguiente comando para entrar al contenedor donde corre la API:

```bash
docker exec -it blitz_backend bash
```

El prompt cambiara a algo como:

```
root@abc123:/app#
```

Eso significa que estas dentro del contenedor.

---

## Paso 4 — Generar el token de Firebase

Dentro del contenedor, ejecuta:

```bash
python3 core/get_firebase_token.py
```

Si todo funciona correctamente, veras una salida como esta:

```
 Obteniendo Firebase ID Token...

 Token obtenido exitosamente!

==========================================================================================
 Email:  test@example.com
 UID:    aBcDeFgHiJkLmNoPqRsTuVwXyZ
==========================================================================================

 TOKEN:
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczov....(token muy largo)

==========================================================================================
```

**Copia el token completo** (la cadena larga que empieza con `eyJ...`).

> **Tip:** Para copiar texto desde la terminal SSH:
> - **Windows CMD / PowerShell:** Selecciona el texto con el mouse y presiona `Enter` o click derecho para copiar
> - **Mac Terminal:** Selecciona con el mouse y `Cmd + C`
> - **PuTTY:** Selecciona con el mouse (se copia automaticamente)

---

## Paso 5 — Autorizar en Swagger UI

Regresa al navegador donde tienes Swagger abierto:

1. Asegurate de que el dropdown **Servers** (arriba) muestre **"Production (VPS IONOS)"**
   - Si muestra "Local Development", cambialo a "Production (VPS IONOS)"

2. Haz clic en el boton verde **Authorize** (arriba a la derecha, con el icono de candado)

3. En el campo de texto que aparece, **pega SOLO el token** (sin la palabra "Bearer"):

   ```
   eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczov....
   ```

   > **IMPORTANTE:** NO escribas "Bearer" antes del token. Swagger lo agrega automaticamente.

4. Haz clic en **Authorize**

5. Haz clic en **Close**

Ahora todos los endpoints mostraran el candado cerrado, indicando que las peticiones se enviaran con autenticacion.

---

## Paso 6 — Probar un endpoint

### Ejemplo: Listar usuarios

1. Busca la seccion **Users** en Swagger
2. Haz clic en **GET /api/user/**
3. Haz clic en **Try it out**
4. Haz clic en **Execute**
5. Debajo aparecera la respuesta del servidor con codigo **200** y los datos en JSON

### Ejemplo: Ver el perfil del usuario autenticado

1. Busca la seccion **Profiles**
2. Haz clic en **GET /api/profile/**
3. Haz clic en **Try it out**
4. Haz clic en **Execute**

### Ejemplo: Crear un recurso (POST)

1. Elige cualquier endpoint **POST** (ej. **POST /api/blitz/**)
2. Haz clic en **Try it out**
3. Modifica el JSON de ejemplo con datos validos
4. Haz clic en **Execute**
5. Si la respuesta es **201**, el recurso se creo exitosamente

---

## Paso 7 — Salir del servidor

Cuando termines, sal del contenedor y del servidor:

```bash
# Salir del contenedor
exit

# Salir del SSH
exit
```

---

## Informacion adicional

### El token expira

Los tokens de Firebase duran **1 hora**. Si al hacer una peticion recibes un error **401 Unauthorized**, el token expiro. Repite los pasos 2-5 para generar uno nuevo.

### Codigos de respuesta comunes

| Codigo | Significado |
|--------|-------------|
| **200** | OK — La peticion fue exitosa |
| **201** | Created — El recurso se creo correctamente |
| **400** | Bad Request — Los datos enviados son invalidos |
| **401** | Unauthorized — Token faltante, invalido o expirado |
| **403** | Forbidden — No tienes permisos para esta accion |
| **404** | Not Found — El recurso no existe |
| **500** | Internal Server Error — Error en el servidor |

### Endpoints disponibles

La API cuenta con los siguientes recursos:

| Recurso | Ruta | Descripcion |
|---------|------|-------------|
| Users | `/api/user/` | Gestion de usuarios |
| Profiles | `/api/profile/` | Perfiles de usuario |
| Groups | `/api/group/` | Grupos |
| Group Memberships | `/api/groupmembership/` | Miembros de grupos |
| Friendships | `/api/friendship/` | Relaciones de amistad |
| Blitz | `/api/blitz/` | Eventos Blitz |
| Blitz Votes | `/api/blitzvote/` | Votaciones en Blitz |
| Blitz Interactions | `/api/blitzinteraction/` | Interacciones en Blitz |
| Matches | `/api/match/` | Matches entre usuarios |
| Match Activities | `/api/matchactivity/` | Actividades de matches |
| Meetup Plans | `/api/meetupplan/` | Planes de encuentro |
| Memories | `/api/memory/` | Recuerdos |
| Memory Photos | `/api/memoryphoto/` | Fotos de recuerdos |
| Chat | `/api/chat/` | Conversaciones |
| Messages | `/api/message/` | Mensajes |
| Notifications | `/api/notification/` | Notificaciones |
| Location Logs | `/api/locationlog/` | Registro de ubicaciones |
| Zone Stats | `/api/zonestats/` | Estadisticas por zona |
| Plans | `/api/plan/` | Planes de suscripcion |
| Plan Features | `/api/planfeature/` | Caracteristicas de planes |
| Subscriptions | `/api/subscription/` | Suscripciones |
| Payments | `/api/payment/` | Pagos |
| Payment Methods | `/api/paymentmethod/` | Metodos de pago |
| Invoices | `/api/invoice/` | Facturas |
| Invoice Items | `/api/invoiceitem/` | Items de factura |
| Coupons | `/api/coupon/` | Cupones |
| Discounts | `/api/discount/` | Descuentos |
| Usage Records | `/api/usagerecord/` | Registros de uso |
| Webhook Logs | `/api/webhooklog/` | Logs de webhooks |

Cada recurso soporta las operaciones estandar REST:
- **GET** `/api/{recurso}/` — Listar todos
- **POST** `/api/{recurso}/` — Crear nuevo
- **GET** `/api/{recurso}/{id}/` — Ver detalle
- **PUT** `/api/{recurso}/{id}/` — Actualizar completo
- **PATCH** `/api/{recurso}/{id}/` — Actualizar parcial
- **DELETE** `/api/{recurso}/{id}/` — Eliminar

### Resumen rapido de comandos

```bash
# Conectarse al servidor
ssh root@198.71.54.171

# Entrar al contenedor
docker exec -it blitz_backend bash

# Generar token
python3 core/get_firebase_token.py

# Salir del contenedor
exit

# Salir del SSH
exit
```

---

## Datos de prueba

| Campo | Valor |
|-------|-------|
| **URL Swagger** | `http://198.71.54.171:8000/api/schema/swagger-ui/` |
| **SSH** | `ssh root@198.71.54.171` |
| **Usuario de prueba** | `test@example.com` |
| **Server en Swagger** | Seleccionar "Production (VPS IONOS)" |
