# 🏫 Mi Primer ABC — Sistema de Control Escolar

Sistema web responsivo para la gestión administrativa del Jardín de Niños **Mi Primer ABC**.

---

## 🗂️ Estructura del Proyecto

```
miprimerabc/
├── index.html                    ← Página de login
├── netlify.toml                  ← Configuración de deploy
├── pages/
│   ├── dashboard.html            ← Panel principal con estadísticas
│   ├── alumnos.html              ← Módulo de alumnos (CRUD + foto)
│   ├── pagos.html                ← Pagos por concepto + pedidos uniforme/bata
│   ├── colegiaturas.html         ← Módulo de colegiaturas mensuales
│   ├── ingresos-gastos.html      ← Dashboard financiero por grado
│   └── configuracion.html        ← Catálogo de precios
├── css/
│   ├── design-system.css         ← Variables, colores por grado, tipografía
│   ├── components.css            ← Botones, cards, forms, modales, badges
│   └── layout.css                ← Sidebar, topbar, grids, responsive
├── js/
│   ├── supabase-config.js        ← ⚠️ Configurar con credenciales reales
│   └── auth.js                   ← Login / sesión / logout / redirección
├── assets/img/logo.png           ← Logo del kínder (PNG fondo transparente)
├── database-schema.sql           ← Esquema completo de BD (instalación nueva)
├── migration-libros-manuales.sql ← Migración si ya existía BD previa
└── storage-setup.sql             ← Configuración del bucket de fotos
```

---

## 🚀 Pasos para poner en producción

### 1. Configurar Supabase

1. Crea una cuenta en [supabase.com](https://supabase.com) y un nuevo proyecto
2. Ve a **Project Settings → API**
3. Edita `js/supabase-config.js` y reemplaza:

```js
const SUPABASE_URL = "https://XXXXXX.supabase.co";
const SUPABASE_ANON_KEY = "eyJ...tu_clave...";
```

### 2. Crear el esquema de base de datos

En **Supabase → SQL Editor → New Query**, ejecuta en este orden:

1. `database-schema.sql` → crea todas las tablas
2. `storage-setup.sql` → configura el bucket de fotos

> Si ya tenías BD con `libros` y `manuales` separados, ejecuta
> `migration-libros-manuales.sql` antes del schema completo.

### 3. Crear el usuario administrador

En **Supabase → Authentication → Users → Add User**:

- Email: el correo de la directora
- Password: contraseña segura
- Marcar "Auto Confirm User"

### 4. Subir el logo

Coloca el logo en `assets/img/logo.png` (PNG con fondo transparente, mínimo 200×200px).

### 5. Deploy en Netlify

1. Sube el proyecto a un repositorio de **GitHub**
2. En [netlify.com](https://netlify.com): **Add new site → Import from Git**
3. Selecciona el repositorio
4. Configuración:
   - **Build command:** _(dejar vacío)_
   - **Publish directory:** `.` _(punto — raíz del proyecto)_
5. Clic en **Deploy** 🚀

---

## ⚠️ Comandos SQL adicionales (BD existente)

Si actualizas un proyecto con datos previos, ejecuta también:

```sql
-- Campo tipo de alumno
ALTER TABLE alumnos
  ADD COLUMN IF NOT EXISTS tipo_alumno TEXT DEFAULT 'nuevo_ingreso';

-- Campo tipo de precio en pedidos uniforme
ALTER TABLE pedidos_uniforme
  ADD COLUMN IF NOT EXISTS tipo_precio TEXT DEFAULT 'nuevo_ingreso';

-- Campos opcionales de alumnos
ALTER TABLE alumnos
  ALTER COLUMN fecha_nacimiento  DROP NOT NULL,
  ALTER COLUMN grado             DROP NOT NULL,
  ALTER COLUMN grupo             DROP NOT NULL,
  ALTER COLUMN nombre_tutor      DROP NOT NULL,
  ALTER COLUMN relacion_tutor    DROP NOT NULL,
  ALTER COLUMN telefono_1        DROP NOT NULL,
  ALTER COLUMN fecha_inscripcion DROP NOT NULL;
```

---

## 🎨 Sistema de Diseño

### Colores de marca

| Variable          | Hex       | Uso                        |
| ----------------- | --------- | -------------------------- |
| `--color-primary` | `#2E9E5B` | Verde — botones, activos   |
| `--color-error`   | `#EF5350` | Rojo — errores, pendientes |
| `--color-warning` | `#F5C842` | Amarillo — pagos parciales |

### Colores por grado

| Grado    | Color                | Variable           |
| -------- | -------------------- | ------------------ |
| Maternal | Azul cielo `#64B5F6` | `--color-maternal` |
| Kínder 1 | Amarillo `#F5C842`   | `--color-kinder1`  |
| Kínder 2 | Rojo `#EF5350`       | `--color-kinder2`  |
| Kínder 3 | Verde `#2E9E5B`      | `--color-kinder3`  |

### Tipografía

- **Headings:** Quicksand (bold, extrabold)
- **Body:** Nunito (regular, semibold, bold)

---

## 🛠️ Stack Tecnológico

| Capa                 | Tecnología                             |
| -------------------- | -------------------------------------- |
| Frontend             | HTML5 + CSS3 + JavaScript Vanilla ES6+ |
| Base de datos        | Supabase (PostgreSQL)                  |
| Autenticación        | Supabase Auth (email + contraseña)     |
| Almacenamiento fotos | Supabase Storage                       |
| Hosting              | Netlify (free tier)                    |

---

## 📋 Módulos del sistema

| Módulo            | Descripción                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------------- |
| Login             | Autenticación con email y contraseña, sesión persistente                                      |
| Dashboard         | Estadísticas de alumnos por grado y accesos rápidos                                           |
| Alumnos           | CRUD completo con foto, tipo de alumno, filtro por grado                                      |
| Pagos             | Inscripción, Material, Libros y Manuales, Uniforme, Bata — con historial, parciales y totales |
| Colegiaturas      | Registro mensual por alumno con drawer de historial                                           |
| Ingresos y Gastos | Dashboard financiero neto por grado y categoría                                               |
| Configuración     | Catálogo de precios Nuevo Ingreso / Reinscripción por grado                                   |

---

## 🔐 Seguridad

- Row Level Security (RLS) en todas las tablas
- Solo usuarios autenticados acceden a los datos
- Headers de seguridad configurados en `netlify.toml`
- Sin credenciales expuestas en el frontend más allá de la `anon key` pública de Supabase

---

_Mi Primer ABC — Sistema de Control Escolar © 2026_
