// API
import { api } from './api';

export const getDepartments = async () => {
  const response = await api.get('/department');
  return response.data;
};


interface AssignDepartmentParams {
  departamentoId?: number;
  salario?: number;
}

export const AssignDepartmentSalary = async (params: AssignDepartmentParams) => {
  const queryParams = new URLSearchParams({
    departamentoId: params.departamentoId?.toString() || '',
    salario: params.salario?.toString() || ''
  });

  const response = await api.patch(`/department?${queryParams.toString()}`);
  console.log(response);
  return response.data;
};
