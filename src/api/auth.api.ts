// API
import { api, setAuthToken } from './api';

// Interfaces
interface LoginParams {
  email: string;
  password: string;
}

export const login = async (params: LoginParams) => {
  const { email, password } = params;
  try {
    const response = await api.post('/auth/login', { email, password });
    setAuthToken(response.data.token);
    return response.data;
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(error.message);
    } else {
      throw new Error('Error logging in.');
    }
  }
};
