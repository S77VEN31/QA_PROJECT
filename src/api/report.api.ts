// API
import api from './api';

// Interfaces
interface ReportDetailParams {
  startDate?: string;
  endDate?: string;
  IDCard?: string;
  departmentID?: string;
  startRange?: number;
  limitRange?: number;
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

export { getReportDetail };
