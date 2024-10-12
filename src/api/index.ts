// API
import { getAuthToken, setupInterceptors } from './api';
// Auth
import { login } from './auth.api';
// Department
import {
  createDepartment,
  getDepartments,
  getEmployeeSalary,
  setDepartmentSalary,
  setEmployeeSalary,
  assignCollaborators,
} from './department.api';
// Fortnight
import { insertFortnight, insertNFortnights } from './fortnight.api';
// Report
import { getReportDetail, getReportTotal } from './report.api';
// Collaborator
import { getCollaboratorName } from './collaborator.api';

export {
  createDepartment,
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
  assignCollaborators,
  getCollaboratorName,
};

export type { CreateDepartmentParams, SetSalaryParams, AssignCollaboratorsParams } from './api.d';
