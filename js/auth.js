/* ============================================================
   MI PRIMER ABC — Módulo de Autenticación
   ============================================================ */

const Auth = (() => {

  /* ----------------------------------------------------------
     Verificar sesión activa al cargar cualquier página
     ---------------------------------------------------------- */
  async function checkSession() {
    const { data: { session } } = await db.auth.getSession();

    const isLoginPage = window.location.pathname.includes('index.html')
      || window.location.pathname === '/'
      || window.location.pathname.endsWith('/');

    if (!session && !isLoginPage) {
      // No hay sesión → redirigir al login
      window.location.href = '/index.html';
      return null;
    }

    if (session && isLoginPage) {
      // Ya tiene sesión → redirigir al dashboard
      window.location.href = '/pages/dashboard.html';
      return session;
    }

    return session;
  }

  /* ----------------------------------------------------------
     Login con email y contraseña
     ---------------------------------------------------------- */
  async function login(email, password) {
    const { data, error } = await db.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  }

  /* ----------------------------------------------------------
     Cerrar sesión
     ---------------------------------------------------------- */
  async function logout() {
    const { error } = await db.auth.signOut();
    if (error) throw error;
    window.location.href = '/index.html';
  }

  /* ----------------------------------------------------------
     Obtener usuario actual
     ---------------------------------------------------------- */
  async function getCurrentUser() {
    const { data: { user } } = await db.auth.getUser();
    return user;
  }

  /* ----------------------------------------------------------
     Escuchar cambios de estado de autenticación
     ---------------------------------------------------------- */
  function onAuthChange(callback) {
    return db.auth.onAuthStateChange((event, session) => {
      callback(event, session);
    });
  }

  return { checkSession, login, logout, getCurrentUser, onAuthChange };
})();

window.Auth = Auth;
