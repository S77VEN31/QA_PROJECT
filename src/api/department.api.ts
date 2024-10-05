import api from './index';

export const getDepartments = async () => {
  const response = await api.get('/departments');
  return response.data;
};
