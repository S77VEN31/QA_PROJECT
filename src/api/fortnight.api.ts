// Axios
import { AxiosError } from 'axios';
// API
import { api } from './api';

// Interfaces
interface FortnightParams {
  timestamp: Date;
}
interface NFortnightParams {
  timestamp: Date;
  n: number;
}

const insertFortnight = async (params: FortnightParams) => {
  const { timestamp } = params;
  console.log(timestamp);
  try {
    const response = await api.post('/fortnight', { timestamp: timestamp.toISOString() });
    return response.status;
  } catch (error) {
    if (error instanceof AxiosError && error.response) {
      throw new Error(error.response.data);
    } else if (error instanceof Error) {
      throw new Error(error.message);
    } else {
      throw new Error('Error insertando quincena.');
    }
  }
};

const insertNFortnights = async (params: NFortnightParams) => {
  const { timestamp, n } = params;
  try {
    const response = await api.put('/fortnight', { timestamp: timestamp.toISOString(), n });
    return response.status;
  } catch (error) {
    if (error instanceof AxiosError && error.response) {
      throw new Error(error.response.data);
    } else if (error instanceof Error) {
      throw new Error(error.message);
    } else {
      throw new Error('Error insertando quincena.');
    }
  }
};

const calculateTax = async (params: { salary: number }) => {
  const queryParams = { ...params };
  const response = await api.get('/fortnight/calculate', { params: queryParams });
  console.log(response);
  return response.data;
};

export { insertFortnight, insertNFortnights, calculateTax };
