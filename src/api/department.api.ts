// API
import { api } from './api';

export const getDepartments = async () => {
  const response = await api.get('/department');
  return response.data;
};
