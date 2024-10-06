// API
import api from './api';

// Interfaces
interface ReportDetailParams {
  date?: string;
  IDCard?: string;
  departmentID?: string;
  startRange?: number;
  endRange?: number;
}

const getReportDetail = async (params: ReportDetailParams) => {
  const response = await api.get(`/report/detail`, {
    params,
  });
  return response.data;
};

export { getReportDetail };
