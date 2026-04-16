-- ============================================================
-- MI PRIMER ABC — Esquema de Base de Datos
-- Supabase / PostgreSQL
-- ============================================================
-- INSTRUCCIONES:
-- Ejecuta este script en el SQL Editor de tu proyecto Supabase
-- (Dashboard → SQL Editor → New Query → Pegar y ejecutar)
-- ============================================================

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLA: alumnos
-- ============================================================
CREATE TABLE IF NOT EXISTS alumnos (
  id                UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  nombre_completo   TEXT NOT NULL,
  fecha_nacimiento  DATE,
  foto_url          TEXT,
  grado             TEXT CHECK (grado IN ('Maternal', 'Kinder 1', 'Kinder 2', 'Kinder 3')),
  grupo             TEXT,
  nombre_tutor      TEXT,
  relacion_tutor    TEXT CHECK (relacion_tutor IN ('Padre', 'Madre', 'Abuelo(a)', 'Otro') OR relacion_tutor IS NULL),
  telefono_1        TEXT,
  telefono_2        TEXT,
  fecha_inscripcion DATE,
  activo            BOOLEAN DEFAULT TRUE,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: precios
-- Catálogo de precios por grado, concepto, nuevo ingreso / reinscripción
-- ============================================================
CREATE TABLE IF NOT EXISTS precios (
  id                UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  grado             TEXT NOT NULL CHECK (grado IN ('Maternal', 'Kinder 1', 'Kinder 2', 'Kinder 3')),
  concepto          TEXT NOT NULL,
  -- Conceptos: 'inscripcion', 'material_escolar', 'libros', 'manuales',
  --            'colegiatura',
  --            'uniforme_jumper', 'uniforme_pantalon', 'uniforme_sueter',
  --            'uniforme_playera_polo', 'uniforme_pants', 'uniforme_chamarra',
  --            'uniforme_playera_deportiva',
  --            'bata_chica', 'bata_mediana', 'bata_grande'
  precio_nuevo_ingreso   NUMERIC(10, 2) DEFAULT 0,
  precio_reinscripcion   NUMERIC(10, 2) DEFAULT 0,
  activo            BOOLEAN DEFAULT TRUE,
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (grado, concepto)
);

-- ============================================================
-- TABLA: pagos
-- Pagos de conceptos no recurrentes (inscripción, libros, etc.)
-- ============================================================
CREATE TABLE IF NOT EXISTS pagos (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  alumno_id       UUID NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
  concepto        TEXT NOT NULL,
  -- Mismo catálogo que precios.concepto
  monto_total     NUMERIC(10, 2) NOT NULL,  -- El monto objetivo del concepto
  tipo_precio     TEXT CHECK (tipo_precio IN ('nuevo_ingreso', 'reinscripcion', 'otro')),
  estado          TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'parcial', 'liquidado')),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: movimientos_pago
-- Registro de cada abono / pago realizado (parcial o total)
-- ============================================================
CREATE TABLE IF NOT EXISTS movimientos_pago (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pago_id     UUID NOT NULL REFERENCES pagos(id) ON DELETE CASCADE,
  monto       NUMERIC(10, 2) NOT NULL,
  fecha_pago  DATE NOT NULL DEFAULT CURRENT_DATE,
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  es_total    BOOLEAN DEFAULT FALSE,  -- TRUE si liquida completamente el concepto
  nota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: pedidos_uniforme
-- Pedidos de uniforme con sus piezas
-- ============================================================
CREATE TABLE IF NOT EXISTS pedidos_uniforme (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  alumno_id       UUID NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
  numero_pedido   SERIAL,
  piezas          JSONB NOT NULL DEFAULT '{}',
  -- Formato: { "jumper": 1, "pantalon": 2, "sueter": 0, ... }
  total_piezas    NUMERIC(10, 2) DEFAULT 0,
  precio_paquete  NUMERIC(10, 2),  -- NULL = usa total de piezas; valor = precio paquete manual
  monto_total     NUMERIC(10, 2) DEFAULT 0,
  estado          TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'parcial', 'liquidado')),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: movimientos_uniforme
-- Abonos a pedidos de uniforme
-- ============================================================
CREATE TABLE IF NOT EXISTS movimientos_uniforme (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pedido_id   UUID NOT NULL REFERENCES pedidos_uniforme(id) ON DELETE CASCADE,
  monto       NUMERIC(10, 2) NOT NULL,
  fecha_pago  DATE NOT NULL DEFAULT CURRENT_DATE,
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  es_total    BOOLEAN DEFAULT FALSE,
  nota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: pedidos_bata
-- Pedidos de bata (talla única por pedido)
-- ============================================================
CREATE TABLE IF NOT EXISTS pedidos_bata (
  id            UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  alumno_id     UUID NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
  numero_pedido SERIAL,
  talla         TEXT NOT NULL CHECK (talla IN ('Chica', 'Mediana', 'Grande')),
  monto_total   NUMERIC(10, 2) DEFAULT 0,
  estado        TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'parcial', 'liquidado')),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: movimientos_bata
-- ============================================================
CREATE TABLE IF NOT EXISTS movimientos_bata (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pedido_id   UUID NOT NULL REFERENCES pedidos_bata(id) ON DELETE CASCADE,
  monto       NUMERIC(10, 2) NOT NULL,
  fecha_pago  DATE NOT NULL DEFAULT CURRENT_DATE,
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  es_total    BOOLEAN DEFAULT FALSE,
  nota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: colegiaturas
-- Registro de colegiatura por alumno por mes
-- ============================================================
CREATE TABLE IF NOT EXISTS colegiaturas (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  alumno_id   UUID NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
  mes         TEXT NOT NULL,
  -- Formato: 'YYYY-MM' (ej. '2025-09')
  anio        INTEGER NOT NULL,
  monto_total NUMERIC(10, 2) NOT NULL,
  tipo_precio TEXT CHECK (tipo_precio IN ('nuevo_ingreso', 'reinscripcion', 'otro')),
  estado      TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'parcial', 'liquidado')),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (alumno_id, mes, anio)
);

-- ============================================================
-- TABLA: movimientos_colegiatura
-- ============================================================
CREATE TABLE IF NOT EXISTS movimientos_colegiatura (
  id             UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  colegiatura_id UUID NOT NULL REFERENCES colegiaturas(id) ON DELETE CASCADE,
  monto          NUMERIC(10, 2) NOT NULL,
  fecha_pago     DATE NOT NULL DEFAULT CURRENT_DATE,
  metodo         TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  es_total       BOOLEAN DEFAULT FALSE,
  nota           TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: egresos
-- Gastos registrados por categoría
-- ============================================================
CREATE TABLE IF NOT EXISTS egresos (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  grado       TEXT NOT NULL CHECK (grado IN ('Maternal', 'Kinder 1', 'Kinder 2', 'Kinder 3')),
  categoria   TEXT NOT NULL,
  -- Mismas categorías que los conceptos de pagos
  monto       NUMERIC(10, 2) NOT NULL,
  fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  descripcion TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TRIGGER: actualizar updated_at automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas con updated_at
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'alumnos', 'pagos', 'pedidos_uniforme', 'pedidos_bata',
    'colegiaturas', 'egresos', 'precios'
  ]
  LOOP
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at()',
      tbl
    );
  END LOOP;
END;
$$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Solo el usuario autenticado puede acceder a sus datos
-- ============================================================
ALTER TABLE alumnos           ENABLE ROW LEVEL SECURITY;
ALTER TABLE precios           ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos             ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_pago  ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos_uniforme  ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_uniforme ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos_bata      ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_bata  ENABLE ROW LEVEL SECURITY;
ALTER TABLE colegiaturas      ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_colegiatura ENABLE ROW LEVEL SECURITY;
ALTER TABLE egresos           ENABLE ROW LEVEL SECURITY;

-- Política: solo usuarios autenticados pueden leer y escribir
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'alumnos', 'precios', 'pagos', 'movimientos_pago',
    'pedidos_uniforme', 'movimientos_uniforme',
    'pedidos_bata', 'movimientos_bata',
    'colegiaturas', 'movimientos_colegiatura', 'egresos'
  ]
  LOOP
    EXECUTE format(
      'CREATE POLICY "Acceso autenticado" ON %I
       FOR ALL TO authenticated
       USING (true) WITH CHECK (true)',
      tbl
    );
  END LOOP;
END;
$$;

-- ============================================================
-- DATOS INICIALES: Precios en cero (para configurar desde el sistema)
-- ============================================================
INSERT INTO precios (grado, concepto, precio_nuevo_ingreso, precio_reinscripcion)
SELECT g, c, 0, 0
FROM (VALUES
  ('Maternal'), ('Kinder 1'), ('Kinder 2'), ('Kinder 3')
) AS grades(g)
CROSS JOIN (VALUES
  ('inscripcion'), ('material_escolar'), ('libros'), ('manuales'), ('colegiatura'),
  ('uniforme_jumper'), ('uniforme_pantalon'), ('uniforme_sueter'),
  ('uniforme_playera_polo'), ('uniforme_pants'), ('uniforme_chamarra'),
  ('uniforme_playera_deportiva'),
  ('bata_chica'), ('bata_mediana'), ('bata_grande')
) AS concepts(c)
ON CONFLICT (grado, concepto) DO NOTHING;

-- ============================================================
-- FIN DEL ESQUEMA
-- ============================================================