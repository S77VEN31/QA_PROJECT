// Axios
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

const setAuthToken = (token: string | null) => {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
};

const setupInterceptors = () => {
  api.interceptors.response.use(
    (response) => response, // Retorna la respuesta normalmente si no hay errores

    (error) => {
      // Verifica si hay una respuesta del servidor
      if (error.response) {
        // Maneja los errores 401 y 403 de forma específica
        if (error.response.status === 401 || error.response.status === 403) {
          // Elimina el token de autenticación
          delete api.defaults.headers.common.Authorization;

          // Redirige al inicio de sesión o página principal
          window.location.href = '/';
        }
      }

      // Para cualquier otro error, rechaza la promesa para que sea manejado en el bloque `catch` en otras partes del código
      return Promise.reject(error);
    }
  );
};

const getAuthToken = () => {
  return api.defaults.headers.common.Authorization;
};

export { api, getAuthToken, setAuthToken, setupInterceptors };

