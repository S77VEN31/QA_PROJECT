// API
import { getAuthToken, setupInterceptors } from './api';
// Auth
import { login } from './auth.api';
// Department
import {
  createDepartment,
  getDepartments,
  getDepartmentTotals,
  getEmployeeSalary,
  setDepartmentSalary,
  setEmployeeSalary,
} from './department.api';
// Fortnight
import { calculateTax, insertFortnight, insertNFortnights } from './fortnight.api';
// Report
import { getReportDetail, getReportTotal } from './report.api';

export {
  createDepartment,
  calculateTax,
  getAuthToken,
  getDepartments,
  getEmployeeSalary,
  getReportDetail,
  getReportTotal,
  insertFortnight,
  insertNFortnights,
  login,
  setDepartmentSalary,
  setEmployeeSalary,
  setupInterceptors,
  getDepartmentTotals,
};

export type {
  CreateDepartmentParams,
  SetSalaryParams,
  SingleFortnightParams,
  MultipleFortnightsParams,
} from './api.d';
