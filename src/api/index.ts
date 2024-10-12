// API
import { getAuthToken, setupInterceptors } from './api';
// Auth
import { login } from './auth.api';
// Department
import {
  createDepartment,
  getDepartmentEmployees,
  getDepartments,
  getDepartmentTotals,
  getEmployeeSalary,
  setDepartmentSalary,
  setEmployeeSalary,
  assignCollaborators,
} from './department.api';
// Fortnight
import { calculateTax, insertFortnight, insertNFortnights } from './fortnight.api';
// Report
import { getReportDetail, getReportTotal } from './report.api';
// Collaborator
import { getCollaboratorName } from './collaborator.api';

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
  getDepartmentEmployees,
  assignCollaborators,
  getCollaboratorName,
};

export type {
  CreateDepartmentParams,
  SetSalaryParams,
  SingleFortnightParams,
  MultipleFortnightsParams,
  AssignCollaboratorsParams,
} from './api.d';
