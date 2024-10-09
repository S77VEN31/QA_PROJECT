// API
import { api } from './api';

// Interfaces
interface ReportDetailParams {
  startDate?: string;
  endDate?: string;
  IDCard?: string;
  departmentID?: string;
  startRange?: number;
  limitRange?: number;
}
interface ReportTotalParams {
  startDate?: string;
  endDate?: string;
  IDCard?: string;
  departmentID?: string;
}

const getReportDetail = async (params: ReportDetailParams) => {
  const queryParams = {
    ...params,
  };

  const response = await api.get(`/report/detail`, {
    params: queryParams,
  });

  return response.data;
};

const getReportTotal = async (params: ReportTotalParams) => {
  const queryParams = {
    ...params,
  };

  const response = await api.get(`/report/total`, {
    params: queryParams,
  });

  return response.data;
};

export { getReportDetail, getReportTotal };
