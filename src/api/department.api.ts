// API
import { api } from './api';
import { CreateDepartmentParams, DepartmentTotalParams, SetSalaryParams } from './api.d';

export const getDepartments = async (query?: string) => {
  const response = await api.get(`/department?cardID=${query}`);
  return response.data;
};

export const getEmployeeSalary = async (cardID: string, departmentID: number) => {
  const response = await api.get(
    `/department/employee?cardID=${cardID}&departmentID=${departmentID}`
  );
  return response.data;
};

export const setDepartmentSalary = async (body: SetSalaryParams) => {
  const response = await api.patch(`/department`, body);
  return response.data;
};

export const setEmployeeSalary = async (body: SetSalaryParams, query: string) => {
  const response = await api.patch(`/department/employee?cardID=${query}`, body);
  return response.data;
};

export const createDepartment = async (body: CreateDepartmentParams) => {
  const response = await api.post('/department', body);
  return response.data;
};

export const getDepartmentTotals = async (params: DepartmentTotalParams) => {
  const queryParams = {
    ...params,
  };

  const response = await api.get(`/department/totals`, {
    params: queryParams,
  });

  return response.data;
};
