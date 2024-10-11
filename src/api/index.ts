// API
import { getAuthToken, setupInterceptors } from './api';
// Auth
import { login } from './auth.api';
// Department
import { assignDepartmentSalary, getDepartments, insertDepartment } from './department.api';
// Fortnight
import { insertFortnight, insertNFortnights } from './fortnight.api';
// Report
import { getReportDetail, getReportTotal } from './report.api';

export {
  assignDepartmentSalary,
  getAuthToken,
  getDepartments,
  getReportDetail,
  getReportTotal,
  insertDepartment,
  insertFortnight,
  insertNFortnights,
  login,
  setupInterceptors,
};
