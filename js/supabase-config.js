/* ============================================================
   MI PRIMER ABC — Configuración de Supabase
   
   INSTRUCCIONES DE CONFIGURACIÓN:
   1. Crea tu proyecto en https://supabase.com
   2. Ve a Project Settings > API
   3. Copia tu Project URL y tu anon/public key
   4. Reemplaza los valores de SUPABASE_URL y SUPABASE_ANON_KEY
   ============================================================ */

const SUPABASE_URL = "https://rwtnenedxbfmsrscubvp.supabase.co";
const SUPABASE_ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dG5lbmVkeGJmbXNyc2N1YnZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MDY0MDIsImV4cCI6MjA5MDQ4MjQwMn0.9MREVWpKprIjpKvzLIj2ar5sb3pGT6GMW1fiBF_ogd0";

// Inicialización del cliente de Supabase
const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Exportar para uso en otros módulos
window.db = db;

console.log("✅ Supabase inicializado correctamente — Mi Primer ABC");
