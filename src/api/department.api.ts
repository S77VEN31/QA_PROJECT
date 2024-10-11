// API
import api from './api';

export const getDepartments = async () => {
  const response = await api.get('/department');
  return response.data;
};


interface AssignDepartmentParams {
  departamentoId?: number;
  salario?: number;
}

export const assignDepartmentSalary = async (params: AssignDepartmentParams) => {
  const queryParams = new URLSearchParams({
    departamentoId: params.departamentoId?.toString() || '',
    salario: params.salario?.toString() || ''
  });

  const response = await api.patch(`/department?${queryParams.toString()}`);
  console.log(response);
  return response.data;
};

export const insertDepartment = async (depNombre: string) => {
  const response = await api.post(`/department?depNombre=${depNombre}`);
  console.log(response);
  return response.data;
};

