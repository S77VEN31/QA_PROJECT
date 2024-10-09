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
    (response) => response,
    (error) => {
      if (error.response?.status === 401 || error.response?.status === 403) {
        delete api.defaults.headers.common.Authorization;
      }
    }
  );
};

const getAuthToken = () => {
  return api.defaults.headers.common.Authorization;
};

export { api, getAuthToken, setAuthToken, setupInterceptors };
