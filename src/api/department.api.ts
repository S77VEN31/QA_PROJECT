// API
import { api } from './api';

export const getDepartments = async () => {
  const response = await api.get('/department');
  return response.data;
};

interface AssignDepartmentParams {
  departamentID?: number;
  salary?: number;
  children?: number;
  spouse?: boolean;
  percentage?: number;
}

export const assignDepartmentSalary = async (params: AssignDepartmentParams) => {
  const body = {
    ...params,
  };

  console.log(body);

  const response = await api.patch(`/department`, body);
  console.log(response);
  return response.data;
};

export const insertDepartment = async (depNombre: string) => {
  const response = await api.post(`/department?depNombre=${depNombre}`);
  console.log(response);
  return response.data;
};
