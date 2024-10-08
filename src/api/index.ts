// API
import { getAuthToken, setupInterceptors } from './api';
// Auth
import { login } from './auth.api';
// Department
import { getDepartments } from './department.api';
// Fortnight
import { insertFortnight, insertNFortnights } from './fortnight.api';
// Report
import { getReportDetail, getReportTotal } from './report.api';

export {
  getAuthToken,
  getDepartments,
  getReportDetail,
  getReportTotal,
  insertFortnight,
  insertNFortnights,
  login,
  setupInterceptors,
};
